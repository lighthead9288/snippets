import 'dart:async';
import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/common/models/failure.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/usecases/delete_user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_requests.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/providers/auth_provider.dart';

class RequestsListProvider extends ChangeNotifier with BookmarkHolder {
  final AuthProvider auth;
  final GetUserRequestsUseCase getUserRequestsUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final DeleteUserRequestUsecase deleteUserRequestUsecase;
  static const int _requestsLimit = 10;
  List<UserRequest> requests = <UserRequest>[];
  LoadingMode loadingMode = LoadingMode.Online;
  RequestsFilter requestsFilter = RequestsFilter.All;
  dynamic bookmark;

  RequestsListProvider({
    @required this.auth, 
    @required this.getUserRequestsUseCase, 
    @required this.getUserByIdUseCase,
    @required this.deleteUserRequestUsecase
  });

  void onUpdateRequestFilter(RequestsFilter value) {
    requestsFilter = value;
    _clearRequests();
    notifyListeners();
  }

  void onExit() {
    _clearRequests();
  }

  Stream<UserRequestsResponse> getRequests() {
    return getUserRequestsUseCase(auth.user.uid, requestsFilter, _requestsLimit, this)
      .map((response) {
        if (!(response.status is Failure)) {
          loadingMode = (response.status is DataFromServerSuccess) ? LoadingMode.Online : LoadingMode.Offline;
          response.requests.forEach((request) {
            if (request != null) {
              var curRequestInLocal = requests.where((element) => element.id == request.id);
              if (curRequestInLocal.length > 0) {
                var index = requests.indexOf(curRequestInLocal.first);
                requests[index] = request;
              } else {
                requests.add(request);
              }
            }        
          });
          requests.sort((a,b)=>b.dateTime.compareTo(a.dateTime));
          response.requests = requests;
          return response;
        } else {
          return response;
        }        
      });
  }

  Stream<String> getLastMessage(UserRequest request) {
    int messageSymbolsLimit = 15;
    if (request.messages.isEmpty) {
      return isMe(request, request.ownerId)
        ? Stream.value(TextHelper.cutText(request.description, messageSymbolsLimit))
        : getUserByIdUseCase.fromStream(request.ownerId).map((user) => "${user.name} ${user.surname}: ${TextHelper.cutText(request.description, messageSymbolsLimit)}");
    } else {
      var lastMessage = request.messages.last;
      return isMe(request, lastMessage.senderId)
        ? Stream.value(TextHelper.cutText(lastMessage.text, messageSymbolsLimit))
        : getUserByIdUseCase.fromStream(lastMessage.senderId).map((user) => "${user.name} ${user.surname}: ${TextHelper.cutText(lastMessage.text, messageSymbolsLimit)}");
    }
  }

  Stream<String> getRequestOwnerPhoto(UserRequest request) => getUserByIdUseCase.fromStream(request.ownerId).map((user) => user.imageUrl);

  bool isMe(UserRequest request, String userId) => (auth.user.uid == userId);

  void onRequestSelect(
    UserRequest request, 
    Future<void> goToDialog(UserRequest request), 
    Future<RequestSavingResult> goToRequestEditor(UserRequest request), 
    void showRequestSavingResult(RequestSavingResult result)) async {
      if (request.isPublished) {
        await goToDialog(request);
      } else {
        var result = await goToRequestEditor(request);
        if (result!=null) {
          showRequestSavingResult(result);
        }
      }
      _clearRequests();
      notifyListeners();
  }

  Future<void> onAddRequest(Future<RequestSavingResult> goToRequestEditor(), void showRequestSavingResult(RequestSavingResult result)) async {    
    var result = await goToRequestEditor();
    if (result!=null) {
      showRequestSavingResult(result);
    }
    _clearRequests();
    notifyListeners();
  }

  Future<void> onDeleteRequest(UserRequest userRequest) async {
    _clearRequests();
    await deleteUserRequestUsecase(userRequest);
    notifyListeners();
  }

  void _clearRequests() {
    requests.clear();
    bookmark = null;
  }
}

enum LoadingMode {
  Online, 
  Offline
}

