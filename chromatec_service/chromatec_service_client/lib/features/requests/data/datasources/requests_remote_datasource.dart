import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:mutex/mutex.dart';

abstract class RequestsRemoteDataSource {
  Future<UserRequest> getUserRequestById(String id);  
  Future<List<User>> getUsersByDialogMembersList(List members);
  Stream<List<UserRequest>> getUserRequests(String userId, RequestsFilter filter, int limit, BookmarkHolder holder);
  Future<String> createRequest(UserRequest request);
  Future<void> deleteRequest(UserRequest request);
  Future<List<User>> getDealers();
  Future<List<User>> getResponsibleUsers(String category);
  Future<List<User>> getDialogMembers(String requestId);
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
  Stream<UserRequest> getUserRequestStreamById(String requestId);
}

class RequestsFirebaseDataSource extends RequestsRemoteDataSource {
  static const String _dealerFieldName = "dealer";

  final FirebaseFirestore db; 
  Mutex m = Mutex();

  RequestsFirebaseDataSource({@required this.db});

  @override
  Future<void> addDialogMembers(List<User> members, String requestId) async {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);
    var membersIds = members.map((e) => e.id).toList();
    return await ref.update({"members": FieldValue.arrayUnion(membersIds)});
  }

  @override
  Future<void> addMessage(String requestId, Message message) {
    try {
      var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);
      return ref.update({
        "date": Timestamp.now(),
        "messages": FieldValue.arrayUnion([
          {
            "id": message.id,
            "senderId": message.senderId,
            "text": message.text,
            "dateTime": Timestamp.now(),
            "uploads": CommonFirebaseRemoteDataSource.uploadsToServerList(message.uploads)
          }
        ])
      });
    } catch (e) {
    }
  }

  @override
  Future<void> changeMessageUploadsList(String requestId, String messageId, String url, String uploadName, String uploadId, String uploadSize, UploadStatus uploadStatus) async {
    m.protect(() async {
      var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);
      var data = await ref.get();
      List messages = data.data()["messages"];
      messages.forEach((message) {
        String id = message["id"];
        if (id == messageId) {
          List uploads = message["uploads"];
          uploads = CommonFirebaseRemoteDataSource.updateUploadsList(uploads, uploadId, url, uploadName, uploadSize, uploadStatus);
          message["uploads"] = uploads;
        }
      });
      return ref.update({"messages": messages});
    });
  }

  @override
  Future<void> changeRequestUploadsList(String requestId, String url, String uploadId, String uploadName, String uploadSize, UploadStatus uploadStatus) {
    m.protect(() async {
      var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);
      var data = await ref.get();
      List uploads = data.data()["uploads"];
      uploads = CommonFirebaseRemoteDataSource.updateUploadsList(uploads, uploadId, url, uploadName, uploadSize, uploadStatus);
      return ref.update({"uploads": uploads});
    });
  }

  @override
  Future<String> createRequest(UserRequest request) async {
    try {
      List uploadsList = CommonFirebaseRemoteDataSource.uploadsToServerList(request.uploads);
      var userRef = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).add({
        "ownerId": request.ownerId,
        "title": request.title,
        "description": request.description,
        "theme": request.theme,
        "created": Timestamp.now(),
        "date": Timestamp.now(),
        "uploads": uploadsList,
        "members": request.members,
        "messages": request.messages,
        "status": request.status,
        "isPublished": request.isPublished
      });
      return userRef.id;
    } catch (e) {
    }
  }

  @override
  Future<void> deleteRequest(UserRequest request) async {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(request.id);
    return await ref.delete();
  }

  @override
  Future<List<User>> getDialogMembers(String requestId) async {
    var ref = _getUserRequestReference(requestId);
    var dialogRef = await ref.get();
    List members = dialogRef.data()["members"];
    return getUsersByDialogMembersList(members);
  }

  @override
  Future<List<User>> getResponsibleUsers(String category) async {
    List<User> users = <User>[];
    print(category);
    var value = await db
        .collection(ChromatecServiceEndpoints.getDbEndpoints().responsibilitiesCollectionName)
        .where("type", isEqualTo: category)
        .get();
    for (var doc in value.docs) {
      List members = doc.data()["members"];
      var _users = await getUsersByDialogMembersList(members);
      users.addAll(_users);
    }
    return users;
  }

  @override
  Stream<UserRequest> getUserRequestStreamById(String requestId) {
    var ref = _getUserRequestReference(requestId);
    return ref.snapshots().map((snapshot) {     
      return fromFirebaseSnapshotToRequest(snapshot.data(), snapshot.id);
    });
  }

  @override
  Future<UserRequest> getUserRequestById(String id) async {
    var ref = _getUserRequestReference(id);
    var snapshot = await ref.get();
    return fromFirebaseSnapshotToRequest(snapshot.data(), snapshot.id);
  }

  @override
  Future<List<User>> getUsersByDialogMembersList(List members) async {
    List<User> users = <User>[];
    for (var member in members) {
      var userRef = CommonFirebaseRemoteDataSource.getUserReference(member.toString().trim(), db);
      var uRef = await userRef.get();
      users.add(CommonFirebaseRemoteDataSource.fromFirebaseSnapshotToUser(uRef));
    }
    return users;
  }

  @override
  Stream<List<UserRequest>> getUserRequests(String userId, RequestsFilter filter, int limit, BookmarkHolder holder) {
    Query ref;
    if (filter == RequestsFilter.All) {
      ref = (holder.bookmark == null)
          ? db
              .collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName)
              .where("members", arrayContains: userId)
              .orderBy("date", descending: true)
              .limit(limit)
          : db
              .collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName)
              .where("members", arrayContains: userId)
              .orderBy("date", descending: true)
              .startAfterDocument(holder.bookmark)
              .limit(limit);
    } else {
      var isPublished = (filter == RequestsFilter.Published);
      ref = (holder.bookmark == null)
          ? db
              .collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName)
              .where("members", arrayContains: userId)
              .where("isPublished", isEqualTo: isPublished)
              .orderBy("date", descending: true)
              .limit(limit)
          : db
              .collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName)
              .where("members", arrayContains: userId)
              .where("isPublished", isEqualTo: isPublished)
              .orderBy("date", descending: true)
              .startAfterDocument(holder.bookmark)
              .limit(limit);
    }

    return ref.snapshots().map(
      (snapshot) => snapshot.docs.map((_snapshot) {
        try {
          holder.bookmark = _snapshot;
          return fromFirebaseSnapshotToRequest(_snapshot.data(), _snapshot.id);
        } catch (e) {
          
        }
      }).toList()
    );
  } 

  @override
  Future<void> removeDialogMember(User member, String requestId) async {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);
    return await ref.update({
      "members": FieldValue.arrayRemove([member.id])
    });
  }

  @override
  Future<void> updateRequest(UserRequest request) async {
    try {
      var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(request.id);
      List uploadsList = CommonFirebaseRemoteDataSource.uploadsToServerList(request.uploads);
      return await ref.update({
        "title": request.title,
        "description": request.description,
        "theme": request.theme,
        "date": Timestamp.now(),
        "uploads": uploadsList,
        "status": request.status,
        "members": request.members,
        "isPublished": request.isPublished
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<List<User>> getDealers() async {
    var _ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).where("role", isEqualTo: _dealerFieldName);
    var data = await _ref.get();
    return Future.wait(
      data.docs.map((queryDocumentSnapshot) => 
        queryDocumentSnapshot.reference.get().then((documentSnapshot) => 
          CommonFirebaseRemoteDataSource.fromFirebaseSnapshotToUser(documentSnapshot)
        )
      )
    );    
  } 

  DocumentReference _getUserRequestReference(String requestId) => db.collection(ChromatecServiceEndpoints.getDbEndpoints().requestsCollectionName).doc(requestId);

  @visibleForTesting
  UserRequest fromFirebaseSnapshotToRequest(Map<String, dynamic> data, String snapshotId) {
    Timestamp timeStamp = data["date"];
    DateTime dateTime = timeStamp.toDate();
    Timestamp createdAtTimestamp = data["created"];
    DateTime createdAt;
    if (createdAtTimestamp != null) {
      createdAt = createdAtTimestamp.toDate();
    }      
    List messagesFromServer = data["messages"];
    List<Message> messages = <Message>[];
    for (var message in messagesFromServer) {
      var messageServerUploads = message["uploads"] ?? [];
      var messageUploads = CommonFirebaseRemoteDataSource.uploadsFromServer(messageServerUploads);
      Timestamp messageTimeStamp = message["dateTime"];
      messages.add(
        Message(
          id: message["id"],
          senderId: message["senderId"],
          text: message["text"],
          uploads: (messageUploads != null) ? messageUploads : [],
          dateTime: messageTimeStamp.toDate()
        )
      );
    }
    var members = data["members"];
    List serverUploads = data["uploads"];
    var uploads = CommonFirebaseRemoteDataSource.uploadsFromServer(serverUploads);
    return UserRequest(
      id: snapshotId,
      ownerId: data["ownerId"],
      dateTime: dateTime,
      createdAt: createdAt,
      title: data["title"],
      description: data["description"],
      theme: data["theme"],
      status: data["status"],
      members: (members != null) ? members : [],
      messages: (messages != null) ? messages : [],
      uploads: (uploads != null) ? uploads : [],
      isPublished: data["isPublished"]
    );
  }   
}

