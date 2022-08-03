import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/widgets.dart';

abstract class CommonRemoteDataSource {
  Stream<User> getUserStreamById(String id);
  Future<User> getUserFutureById(String id);
}

class CommonFirebaseRemoteDataSource implements CommonRemoteDataSource {
  final FirebaseFirestore db;

  CommonFirebaseRemoteDataSource({@required this.db});

  @override
  Stream<User> getUserStreamById(String id) {
    var ref = getUserReference(id, db);
    return ref.snapshots().map((snapshot) {
      return fromFirebaseSnapshotToUser(snapshot);
    });
  }

  @override
  Future<User> getUserFutureById(String id) async {
    var ref = getUserReference(id, db);
    var snapshot = await ref.get();
    return fromFirebaseSnapshotToUser(snapshot);
  }

  static User fromFirebaseSnapshotToUser(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    Timestamp timestamp = data()["lastSeen"];
    DateTime lastSeen = timestamp.toDate();
    List serverQuizes = data()["quizes"];
    List<String> quizesList = <String>[];
    serverQuizes.forEach((quizId) {
      quizesList.add(quizId);
    });
    return User(snapshot.id, data()["name"], data()["surname"],
      data()["email"], data()["image"], lastSeen, data()["role"], quizesList);
  }

  static DocumentReference getUserReference(String uid, FirebaseFirestore db) => db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).doc(uid);

  static List<Upload> uploadsFromServer(List serverUploads) {
    try {
      List<Upload> uploads = <Upload>[];
      for (var upload in serverUploads) {
        String id = upload["id"];
        String url = upload["upload"];
        String name = upload["name"];
        String size = upload["size"];
        var type = EnumToString.fromString(UploadType.values, upload["type"]);
        var status = EnumToString.fromString(UploadStatus.values, upload["status"]);
        uploads.add(UrlUpload(id, url, name, size, status, type));
      }
      return uploads;
    } catch(e) {
      return [];
    }
  }

  static List uploadsToServerList(List<Upload> uploads) {
    return uploads.map((upload) {
      return {
        "id": upload.id,
        "status": EnumToString.convertToString(upload.status),
        "type": EnumToString.convertToString(upload.type),
        "upload": (upload is UrlUpload) ? upload.upload : "",
        "name": upload.name,
        "size": upload.size
      };
    }).toList();
  }

  static List updateUploadsList(List uploads, String uploadId, String url,
    String uploadName, String uploadSize, UploadStatus uploadStatus) {
    return uploads.map((upload) {
      String id = upload["id"];
      if (id == uploadId) {
        upload["upload"] = url;
        upload["name"] = uploadName;
        upload["size"] = uploadSize;
        upload["status"] = EnumToString.convertToString(uploadStatus);
      }
      return upload;
    }).toList();
  }  
}