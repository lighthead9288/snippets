import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/services/local_db.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/data/models/user_request_model.dart';
import 'package:core/core.dart';
import 'package:sembast/sembast.dart';

abstract class RequestsLocalDataSource {
  Stream<UserRequest> getUserRequestById(String id);
  Stream<List<UserRequest>> getUserRequests(
      String userId, RequestsFilter filter, int limit,
      BookmarkHolder holder);
  void refreshUserRequests(List<UserRequest> requests, String userId,
      RequestsFilter filter, int limit,
      {BookmarkHolder holder});
  Future<List<User>> getDialogMembers(String requestId);
  Stream<UserRequest> getUserMessages(String requestId, int limit);
}

class RequestsLocalDataSourceImpl extends RequestsLocalDataSource {
  static const String _usersBoxName = "Users";
  static const String _requestsBoxName = "Requests";
  static const String _responsibilitiesBoxName = "Responsibilities";
  static const String _dealerReportsBoxName = "DealerReports";
  static const String _quizesBoxName = "Quizes";
  static const String _quizQuestionsBoxName = "QuizQuestions";
  static const String _quizAnswersBoxName = "QuizAnswers";
  static const String _dealerFieldName = "dealer";

  final _requestsFolder = intMapStoreFactory.store(_requestsBoxName);

  Future<Database> get _db async => await AppDatabase.instance.database;
  @override
  Future<List<User>> getDialogMembers(String requestId) {
    // TODO: implement getDialogMembersgit
    throw UnimplementedError();
  }

  @override
  Stream<UserRequest> getUserMessages(String requestId, int limit) {
    // TODO: implement getUserMessages
    throw UnimplementedError();
  }

  @override
  Stream<UserRequest> getUserRequestById(String id) {
    // TODO: implement getUserRequestById
    throw UnimplementedError();
  }

  @override
  Stream<List<UserRequest>> getUserRequests(
      String userId, RequestsFilter filter, int limit,
      BookmarkHolder holder) {
    return _getUserRequests(userId, filter, limit, holder).asStream();
  }

  Future<List<UserRequest>> _getUserRequests(
      String userId, RequestsFilter filter, int limit,
      BookmarkHolder holder) async {
    var dbFilters = [_getDialogMembersFilter(userId)];
    if (filter != RequestsFilter.All) {
      dbFilters.add(
          Filter.equals('isPublished', filter == RequestsFilter.Published));
    }
    var finder = Finder(
      filter: Filter.and(dbFilters),
      sortOrders: [SortOrder('dateTime', false)],
      limit: limit,
    );
    if (holder.bookmark != null) {
      finder.start = Boundary(record: holder.bookmark);
    }
    final snapshots = await _requestsFolder.find(await _db, finder: finder);
    return snapshots.map((snapshot) {
      holder.bookmark = snapshot;
      return UserRequestModel.fromJson(snapshot.value);
    }).toList();
  }

  Future<List<UserRequest>> _getAllUserRequests(String userId) async {
    final snapshots = await _requestsFolder.find(await _db,
        finder: Finder(filter: _getDialogMembersFilter(userId)));
    return snapshots.map((snapshot) {
      return UserRequestModel.fromJson(snapshot.value);
    }).toList();
  }

  Filter _getDialogMembersFilter(String userId) {
    return Filter.custom((record) {
      var members = record["members"];
      if (members is Iterable) {
        return members.contains(userId);
      }
      return false;
    });
  }

  @override
  void refreshUserRequests(List<UserRequest> requests, String userId,
      RequestsFilter filter, int limit,
      {BookmarkHolder holder}) async {
    print('Refresh...');
    var requestsInDb = await _getAllUserRequests(userId);
    _refreshExistedRequests(requests, requestsInDb);
  }

  void _refreshExistedRequests(List<UserRequest> requestsFromServer, List<UserRequest> requestsInDb) {
    requestsFromServer.forEach((requestFromServer) async {
      bool isRequestInDb = requestsInDb.map((e) => e.id).contains(requestFromServer.id);
      var model = UserRequestModel(
          id: requestFromServer.id,
          ownerId: requestFromServer.ownerId,
          title: requestFromServer.title,
          description: requestFromServer.description,
          dateTime: requestFromServer.dateTime,
          isPublished: requestFromServer.isPublished,
          theme: requestFromServer.theme,
          status: requestFromServer.status,
          members: requestFromServer.members,
          messages: requestFromServer.messages,
          uploads: requestFromServer.uploads);
      if (!isRequestInDb) {
        var key = await _requestsFolder.add(await _db, model.toJson());
        print("${requestFromServer.title} - key: $key");
      } 
      else {
          print("${requestFromServer.title} updated");
          await _requestsFolder.update(await _db, model.toJson(), finder: Finder(filter: Filter.equals('id', requestFromServer.id)));
      }      
    });
  }

}
