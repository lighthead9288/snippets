import 'package:chromatec_service/common/interfaces/pick_uploads_provider.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/change_request_uploads_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/create_user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_request_by_id.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_users_by_dialog_members_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/update_user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/support_subject.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:chromatec_service/services/pick_uploads_manager.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class RequestEditorProvider extends ChangeNotifier with PickUploadsProvider {
  final GetUserRequestByIdUseCase getUserRequestByIdUseCase;
  final GetUsersByDialogMembersListUseCase getUsersByDialogMembersListUseCase;
  final CreateUserRequestUseCase createUserRequestUseCase;
  final UpdateUserRequestUseCase updateUserRequestUseCase;
  final ChangeRequestUploadsListUseCase changeRequestUploadsListUseCase;
  final AuthProvider auth;
  final PickUploadsManager uploadsManager;
  final TasksProvider tasksProvider;
  List<Upload> uploads = <Upload>[];
  bool isRequestLoading = false;

  @visibleForTesting
  bool isInitialLoading = true;
  
  static const themeItems = ["Soft", "Hardware", "Other"];
  String title = "";
  String description = "";
  String theme = themeItems[0];
  SupportSubject support;

  RequestEditorProvider({
    @required this.auth, 
    @required this.getUserRequestByIdUseCase, 
    @required this.getUsersByDialogMembersListUseCase, 
    @required this.createUserRequestUseCase,
    @required this.updateUserRequestUseCase,
    @required this.changeRequestUploadsListUseCase,
    @required this.uploadsManager,
    @required this.tasksProvider
  });

  Future<UserRequest> getUserRequestById(String requestId, String chromatecLabel, void onTimeoutExpired(), void onError()) async {
    try {
      var userRequest = await getUserRequestByIdUseCase(requestId).timeout(Duration(seconds: 60), onTimeout: () {
        onTimeoutExpired();
        return;
      });
      List<User> members = await getUsersByDialogMembersListUseCase(userRequest.members);
      _setSupportSubjectByMembers(members, chromatecLabel);
      if (isInitialLoading) {
        title = userRequest.title;
        description = userRequest.description;
        theme = userRequest.theme;
      }    
      _updateUploadsList(userRequest.uploads);
      isInitialLoading = false;
      return userRequest;
    } catch(e) {
      onError();
      return Future.value(UserRequest());
    }
    
  }

  void _setSupportSubjectByMembers(List<User> members, String chromatecLabel) {    
    if (((members.length == 1) && (members.first.id == auth.user.uid)) || (support!=null)) return;
    var dealers = members.where((member) => member.role == "dealer");
    support = (dealers.isEmpty) ? SupportSubject(chromatecLabel, members) : SupportSubject("${dealers.first.name} ${dealers.first.surname}", members);
  }

  void _updateUploadsList(List<Upload> serverUploads) {
    serverUploads.forEach((serverUpload) { 
      var curUploadInLocal = uploads.where((upload) => upload.id == serverUpload.id);
      if (curUploadInLocal.length > 0) {
        var index = uploads.indexOf(curUploadInLocal.first);
        uploads[index] = serverUpload;
      } else if (isInitialLoading) {
        uploads.add(serverUpload);
      }  
    });    
  }

  Future<void> onSelectSupportSubject(String requestId, Future<SupportSubject> goToSelectSupport(),
    void onSuccess(), void onTimeoutExpired(), void onError()) async {
    var result = await goToSelectSupport();
    if (result is SupportSubject) {
      support = result;
      onPublish(requestId, onSuccess, onTimeoutExpired, onError);
    }
  }

  void removeUpload(int index) {
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

  void onPublish(String requestId,  void onSuccess(), void onTimeoutExpired(), void onError()) {
    try {
      _setLoading();
      var result = (requestId == null)
        ? createUserRequest(auth.user.uid, title, description, theme, (support!=null) ? support.users : [], onTimeoutExpired, onError)
        : updateUserRequest(auth.user.uid, requestId, title, description, theme, (support!=null) ? support.users : [], onTimeoutExpired, onError);
      result.whenComplete(() {
        _releaseLoading();
        onSuccess();
      });
    } catch (e) {
      _releaseLoading();
      onError();
    }
  }
  

  void onSave(String requestId, void onSuccess(), void onTimeoutExpired(), void onError()) {
    try {
      _setLoading();
      var result = (requestId == null)
        ? createUserRequest(auth.user.uid, title, description, theme, (support!=null) ? support.users : [], onTimeoutExpired, onError, isPublished: false)
        : updateUserRequest(auth.user.uid, requestId, title, description, theme, (support!=null) ? support.users : [], onTimeoutExpired, onError, isPublished: false);
      result.whenComplete(() {
        _releaseLoading();
        onSuccess();
      });
    } catch (e) {
      _releaseLoading();
      onError();
    }
  }

  void _setLoading() {
    isRequestLoading = true;
    notifyListeners();
  }

  void _releaseLoading() {
    isRequestLoading = false;
    notifyListeners();
  }

  @visibleForTesting
  Future<void> createUserRequest(String userId, String title, String description, String theme, List<User> supportMembers, 
    void onTimeoutExpired(), void onError(), {bool isPublished = true}) async {
    try {
      var _uploads = _takeUploadsOnLoading(uploads);
      var members = supportMembers.map((e) => e.id).toList();
      members.add(userId);      
      var requestId = await createUserRequestUseCase(
        UserRequest(
          ownerId: userId,
          title: title,
          description: description,
          theme: theme,
          status: "Opened",
          members: members,
          messages: [],
          uploads: _uploads,
          isPublished: isPublished
        )
      ).timeout(Duration(seconds: 60), onTimeout: () {
          onTimeoutExpired();
          return;
      });      
      print("${DateTime.now().toUtc()}: Request $requestId was created");

      tasksProvider
      .createTaskListByUploads(
        _uploads,
        userId, 
        (url, upload) {
          _addUploadToRequest(requestId, url, upload, UploadStatus.Loaded);
        }
      );
    } catch(e) {
      onError();
    }
  }

  @visibleForTesting
  Future<void> updateUserRequest(String userId, String requestId, String title, String description, String theme, List<User> supportMembers, 
    void onTimeoutExpired(), void onError(), {bool isPublished = true}) async {
    try {
      var _uploads = _takeUploadsOnLoading(uploads);
      var members = supportMembers.map((e) => e.id).toList();
      members.add(userId);
      var request = UserRequest(
        id: requestId,
        ownerId: userId,
        title: title,
        description: description,
        theme: theme,
        status: "Opened",
        members: members,
        messages: [],
        uploads: _uploads,
        isPublished: isPublished
      );
      await updateUserRequestUseCase(request).timeout(Duration(seconds: 60), onTimeout:() => onTimeoutExpired());
      print("${DateTime.now().toUtc()}: Request $requestId update was started...");
      var unloadedUploads = _uploads.where((element) => element is FileUpload).toList();
      
      tasksProvider
      .createTaskListByUploads(
        unloadedUploads,
        userId,
        (snapshot, upload) => _addUploadToRequest(requestId, snapshot, upload, UploadStatus.Loaded)        
      );    
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

  void _addUploadToRequest(String requestId, String url, FileUpload upload, UploadStatus status) async =>
    await changeRequestUploadsListUseCase(requestId, url, upload.id, upload.name, upload.size, status);
}