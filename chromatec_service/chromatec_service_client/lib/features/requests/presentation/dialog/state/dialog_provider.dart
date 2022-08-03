import 'package:chromatec_service/common/interfaces/pick_uploads_provider.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:chromatec_service/features/requests/domain/usecases/add_message.dart';
import 'package:chromatec_service/features/requests/domain/usecases/change_message_uploads_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_dialog_data.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:chromatec_service/services/pick_uploads_manager.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class DialogProvider extends ChangeNotifier with PickUploadsProvider {
  final AuthProvider auth;
  final PickUploadsManager uploadsManager;
  final TasksProvider tasksProvider;
  final GetDialogDataUseCase getDialogDataUseCase;
  final AddMessageUseCase addMessageUseCase;
  final ChangeMessageUploadsListUseCase changeMessageUploadsListUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  DialogButtonProvider dialogButton;
  List<Upload> uploads = <Upload>[]; 
  var _uuid = Uuid();
  String messageText = "";
  String theme = "";
  int _finishMessageNumber = 0;
  List<Message> messages = <Message>[];
  int _requestHashCode = 0;
  bool _isInitialLoading = true;
  bool isNewMessage = false;
  Stream<List<Message>> messagesStream;
  final int limit = 10;
  bool isNeedFetchData = true;
  bool isError = false;

  DialogProvider({
    @required this.auth, 
    @required this.uploadsManager, 
    @required this.tasksProvider, 
    @required this.getDialogDataUseCase, 
    @required this.addMessageUseCase,
    @required this.changeMessageUploadsListUseCase,
    @required this.getUserByIdUseCase
  });  

  Stream<List<Message>> getUserMessages(String requestId) {
    try {
      messagesStream = getDialogDataUseCase(requestId)
        .map((request) {
          if (!request.members.contains(auth.user.uid)) {
            isError = true;
            return [];
          }

          theme = request.theme;
          request.messages.insert(0, Message(
            senderId: request.ownerId,
            text: request.description,
            dateTime: request.createdAt,
            uploads: request.uploads
          ));
          if ((request.hashCode != _requestHashCode) && (messages.isNotEmpty)) {
            _onUpdating(request.messages); 
          } else {
            _filterMessages(request, limit);
          }
          _requestHashCode = request.hashCode;
          isNeedFetchData = request.messages.length != messages.length;
          return messages;
        });
      return messagesStream;
    } catch(e) {
      isError = true;
      return Stream.value(<Message>[]);
    }    
  }

  Stream<String> getMessageSenderName(String senderId) => getUserByIdUseCase.fromStream(senderId).map((user) => "${user.name} ${user.surname}");
  
  Stream<String> getMessageSenderImageUrl(String senderId) => getUserByIdUseCase.fromStream(senderId).map((user) => user.imageUrl);

  void onAddMessage(String requestId, void onTimeoutExpired(), void onError()) async {
    await _addNewMessage(requestId, auth.user.uid, messageText,
        () {
      print('Send message timeout expired');
    }, () {
      print('Send message error');
    });   
  }

  void onRemoveUpload(int index) {
    uploads.removeAt(index);
    notifyListeners();
  }

  void onMakePhoto() async {
    var photo = await uploadsManager.makePhoto();
    uploads.add(photo);
    notifyListeners();
  }

  void onMakeVideo() async {
    var video = await uploadsManager.makeVideo();
    uploads.add(video);
    notifyListeners();
  }

  void onPickFiles() async {
    var files = await uploadsManager.pickFiles();
    uploads.addAll(files);
    notifyListeners();
  }

  void onPickPhotos() async {
    var photos = await uploadsManager.pickPhotos();
    uploads.addAll(photos);
    notifyListeners();
  }

  void onPickVideos() async {
    var video = await uploadsManager.pickVideo();
    uploads.add(video);
    notifyListeners();
  }

  void onReachScrollBottom() {
   dialogButton.state = DialogButtonState.None;
  }

  void onScrollFromBottom() {
    dialogButton.state = DialogButtonState.Enabled;
  }

  String getMessageDateTimeStringView(DateTime dateTime) {
    if (dateTime == null) {
      return "";
    }
    var local = dateTime.toLocal();
    return DateFormat.yMd().add_Hm().format(local);
  }

  void _filterMessages(UserRequest request, int limit) {
    if (_isInitialLoading) {
      _finishMessageNumber = request.messages.length;
    }    
    var startMessageNumber = (_finishMessageNumber < limit) ? 0 : _finishMessageNumber - limit;
    messages.insertAll(0, request.messages.sublist(startMessageNumber, _finishMessageNumber));
    _finishMessageNumber = startMessageNumber;
    _isInitialLoading = false;
  }

  void _onUpdating(List<Message> updatedMessages) {
    isNewMessage = updatedMessages.last.dateTime.isAfter(messages.last.dateTime);
    if (isNewMessage && (dialogButton.state != DialogButtonState.None)) {
      dialogButton.state = DialogButtonState.Updated;
    }      
    var loadedMessages = messages;
    var loadedMessageSearchingResults = <Message>[];
    for(var loadedMessage in loadedMessages) {
        loadedMessageSearchingResults = updatedMessages.where((_message) => (loadedMessage.id == _message.id)).toList();
        if (loadedMessageSearchingResults.isNotEmpty) {
          var index = ((updatedMessages.length - updatedMessages.indexOf(loadedMessageSearchingResults.first) >= limit) 
                    || (updatedMessages.length <= limit)) 
                        ? updatedMessages.indexOf(loadedMessageSearchingResults.first) 
                        : updatedMessages.length - limit;
          messages = updatedMessages.sublist(index);
          _finishMessageNumber = index;
          break;
        }
      }
    if (loadedMessageSearchingResults.isEmpty) {
        var index = (updatedMessages.length >= limit) ? 0 : updatedMessages.length - limit;
        messages = updatedMessages.sublist(index);
        _finishMessageNumber = index;
    }
  }  

  Future<void> _addNewMessage(String requestId, String senderId, String text, void onTimeoutExpired(), void onError()) async {
    try {
      var messageId = _uuid.v1();
      var message = Message(id: messageId, senderId: senderId, text: text, uploads: uploads);
      var _uploads = _takeUploadsOnLoading(uploads);

      await addMessageUseCase(requestId, message)
        .timeout(Duration(seconds: 60), onTimeout: () {
          onTimeoutExpired();
        });
      print('Message was successful added!');
      var unloadedUploads = _uploads.where((element) => element is FileUpload).toList();
      tasksProvider
      .createTaskListByUploads(
        unloadedUploads,
        senderId,
        (url, upload) => _addUploadToMessage(requestId, messageId, url, upload, UploadStatus.Loaded)        
      );
      uploads.clear();   
    } catch(e) {
      onError();
    }
  }

  List<Upload> _takeUploadsOnLoading(List<Upload> uploads) {
    List<Upload> result = [];
    for (var upload in uploads) {
      Upload loadingUpload = upload;
      if (upload.status!=UploadStatus.Loaded) {
        loadingUpload.status = UploadStatus.Loading;
      }           
      result.add(loadingUpload);
    }
    return result;
  }  

  void _addUploadToMessage(String requestId, String messageId, String url, FileUpload upload, UploadStatus status) async =>
    await changeMessageUploadsListUseCase(requestId, messageId, url, upload, status);    
}

enum DialogButtonState {
  None,
  Enabled,
  Updated
}

class DialogButtonProvider extends ChangeNotifier {
  DialogButtonState _state = DialogButtonState.None;
  DialogButtonState get state => _state;
  set state(DialogButtonState value) {
    _state = value;
    notifyListeners();
  }
}
