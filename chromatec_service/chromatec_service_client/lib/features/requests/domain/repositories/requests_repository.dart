import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:core/core.dart';

abstract class RequestsRepository {
  Stream<UserRequestsResponse> getUserRequests(String userId, RequestsFilter filter, int limit, BookmarkHolder holder);
  Future<UserRequest> getUserRequestById(String id);
  Stream<UserRequest> getUserRequestStreamById(String id);
  Future<String> createRequest(UserRequest request);
  Future<void> deleteRequest(UserRequest request);
  Future<List<User>> getDealers();
  Future<List<User>> getResponsibleUsers(String category);
  Future<List<User>> getDialogMembers(String requestId);
  Future<List<User>> getUsersByDialogMembersList(List members);
  Future<void> addDialogMembers(List<User> members, String requestId);
  Future<void> removeDialogMember(User member, String requestId);
  Future<void> updateRequest(UserRequest request);
  Future<void> addMessage(String requestId, Message message);
  Future<void> changeRequestUploadsList(
      String requestId,
      String url,
      String uploadId,
      String uploadName,
      String uploadSize,
      UploadStatus uploadStatus);
  Future<void> changeMessageUploadsList(
      String requestId,
      String messageId,
      String url,
      String uploadName,
      String uploadId,
      String uploadSize,
      UploadStatus uploadStatus);
  
  
}