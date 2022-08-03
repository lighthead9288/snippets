import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/common/models/failure.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class RequestsRepositoryImpl extends RequestsRepository {

  final RequestsRemoteDataSource remoteDataSource;

  RequestsRepositoryImpl({@required this.remoteDataSource});

  @override
  Stream<UserRequestsResponse> getUserRequests(String userId, RequestsFilter filter, int limit, BookmarkHolder holder) {
    try {      
      return remoteDataSource.getUserRequests(userId, filter, limit, holder)      
        .map((requests) {
          return UserRequestsResponse(DataFromServerSuccess(), requests: requests);
        });      
    } catch(e) {
      return Stream.value(UserRequestsResponse(ServerFailure()));
    }    
  }

  @override
  Future<UserRequest> getUserRequestById(String id) async {
    try {
      return await remoteDataSource.getUserRequestById(id);
    } catch(e) {
    }
  }

  @override
  Future<List<User>> getUsersByDialogMembersList(List members) async {
    try {
      return await remoteDataSource.getUsersByDialogMembersList(members);
    } catch(e) {
    }
  }   

  @override
  Future<void> addDialogMembers(List<User> members, String requestId) {
    return remoteDataSource.addDialogMembers(members, requestId);
  }

  @override
  Future<void> addMessage(String requestId, Message message) {
    return remoteDataSource.addMessage(requestId, message);
  }

  @override
  Future<void> changeMessageUploadsList(String requestId, String messageId, String url, String uploadName, String uploadId, String uploadSize, UploadStatus uploadStatus) {
    return remoteDataSource.changeMessageUploadsList(requestId, messageId, url, uploadName, uploadId, uploadSize, uploadStatus);
  }

  @override
  Future<void> changeRequestUploadsList(String requestId, String url, String uploadId, String uploadName, String uploadSize, UploadStatus uploadStatus) async {
    return await remoteDataSource.changeRequestUploadsList(requestId, url, uploadId, uploadName, uploadSize, uploadStatus);
  }

  @override
  Future<String> createRequest(UserRequest request) async {
    return await remoteDataSource.createRequest(request);
  }

  @override
  Future<void> deleteRequest(UserRequest request) async {
    return await remoteDataSource.deleteRequest(request);
  }

  @override
  Future<List<User>> getDialogMembers(String requestId) {
    return remoteDataSource.getDialogMembers(requestId);
  }

  @override
  Future<List<User>> getResponsibleUsers(String category) {
    return remoteDataSource.getResponsibleUsers(category);
  }

  @override
  Future<void> removeDialogMember(User member, String requestId) {
    return remoteDataSource.removeDialogMember(member, requestId);
  }

  @override
  Future<void> updateRequest(UserRequest request) {
    return remoteDataSource.updateRequest(request);
  }

  @override
  Stream<UserRequest> getUserRequestStreamById(String id) {
    return remoteDataSource.getUserRequestStreamById(id);
  }

  @override
  Future<List<User>> getDealers() {
    return remoteDataSource.getDealers();
  }
}