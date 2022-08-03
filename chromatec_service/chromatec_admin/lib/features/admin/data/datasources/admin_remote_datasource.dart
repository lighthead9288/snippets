import 'dart:convert';
import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;

abstract class AdminRemoteDatasource {
  Future<List<User>> getUsers();
  Future<List<User>> getEmployee();
  Future<List<Project>> getProjects();
  Future<List<RegistrationRequest>> getRegistrationRequests();
  Future<void> changeRegistrationRequestStatus(String id, RegistrationRequestStatus status);
  Future<void> changeUserRole(String userId, String role);
  Future<void> updateResponsibilitiesMembersList(String projectId, List<String> members);
  Future<bool> deleteUser(String userId);
  Future<bool> createUser(String email, String password, String name, String surname, String role);
}

class AdminFirebaseDatasource extends AdminRemoteDatasource {
  final FirebaseFirestore db;
  final FirebaseFunctions instance;  

  AdminFirebaseDatasource({@required this.db, @required this.instance});

  @override
  Future<List<User>> getUsers() async {
    var data = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).orderBy("lastSeen", descending: true).get();
    return Future.wait(
      data.docs.map((queryDocumentSnapshot) => 
        queryDocumentSnapshot.reference.get().then((documentSnapshot) => 
          CommonFirebaseRemoteDataSource.fromFirebaseSnapshotToUser(documentSnapshot)
        )
      )
    );    
  }

  @override
  Future<List<User>> getEmployee() async {
    var data = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).where("role", isEqualTo: _employeeRoleName).get();
    return Future.wait(
      data.docs.map((queryDocumentSnapshot) => 
        queryDocumentSnapshot.reference.get().then((documentSnapshot) => 
          CommonFirebaseRemoteDataSource.fromFirebaseSnapshotToUser(documentSnapshot)
        )
      )
    );
  }

  @override
  Future<void> changeUserRole(String userId, String role) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).doc(userId);
    return ref.update({
      "role": role
    });
  }

  @override
  Future<bool> deleteUser(String userId) async {
    HttpsCallable callable = instance.httpsCallable(ChromatecServiceEndpoints.getBackendEndpoints().deleteUserFunctionName, options: HttpsCallableOptions(timeout: const Duration(seconds: 30)));
    return await callable({
      "userId": userId
    }).then((value) {
      var isDeleted = value.data["isDeleted"];
      return isDeleted;
    }).catchError((e) => false);
  }

  @override
  Future<bool> createUser(String email, String password, String name, String surname, String role) async {
    HttpsCallable callable = instance.httpsCallable(ChromatecServiceEndpoints.getBackendEndpoints().createUserFunctionName, options: HttpsCallableOptions(timeout: const Duration(seconds: 30)));
    return await callable({
      "email": email,
      "password": password,
      "name": name,
      "surname": surname,
      "role": role,
    }).then((value) {
      var isCreated = value.data["isCreated"];
      return isCreated;
    }).catchError((e) => false);
  }

  @override
  Future<List<Project>> getProjects() async {
    var data = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().responsibilitiesCollectionName).get();
    var projects = Future.wait(
      data.docs.map((queryDocumentSnapshot) => 
        queryDocumentSnapshot.reference.get().then((documentSnapshot) => 
          _fromFirebaseSnapshotToProject(documentSnapshot)
        )
      )
    );
    return projects;   
  }

  @override
  Future<void> updateResponsibilitiesMembersList(String projectId, List<String> members) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().responsibilitiesCollectionName).doc(projectId);
    return ref.update({
      "members": members
    });
  }

  @override
  Future<void> changeRegistrationRequestStatus(String id, RegistrationRequestStatus status) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().registrationRequestsCollectionName).doc(id);
    return ref.update({
      "status": EnumToString.convertToString(status)
    });
  } 

  @override
  Future<List<RegistrationRequest>> getRegistrationRequests() async {
    var data = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().registrationRequestsCollectionName)
      .where("status", isNotEqualTo: "Confirmed")
      .orderBy("status")
      .orderBy("dateTime", descending: true)
      .get();
    return Future.wait(
      data.docs.map((queryDocumentSnapshot) => 
        queryDocumentSnapshot.reference.get().then((documentSnapshot) => 
          _fromFirebaseSnapshotToRegistrationRequest(documentSnapshot)
        )
      )
    ); 
  }

  RegistrationRequest _fromFirebaseSnapshotToRegistrationRequest(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    Timestamp timestamp = data()["dateTime"];
    DateTime dateTime = timestamp.toDate();
    var request = RegistrationRequest(
      id: snapshot.id, 
      email: data()["email"], 
      name: data()["name"], 
      surname: data()["surname"], 
      dateTime: dateTime, 
      status: EnumToString.fromString(RegistrationRequestStatus.values, data()["status"]), 
      uploads: CommonFirebaseRemoteDataSource.uploadsFromServer(data()["uploads"])
    );
    return request;
  } 

  Project _fromFirebaseSnapshotToProject(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    var members = data()["members"] as List;
    return Project(id: snapshot.id, name: data()["name"], type: data()["type"], members: members.map((member) => member.toString()).toList());
  }

    
}

class AdminRemoteDesktopDatasource extends AdminRemoteDatasource {
  final Firestore db;

  AdminRemoteDesktopDatasource({@required this.db});

  @override
  Future<void> changeUserRole(String userId, String role) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).document(userId);
    return ref.update({
      "role": role
    });
  }  

  @override
  Future<bool> createUser(String email, String password, String name, String surname, String role) async {
    var url = Uri.parse(ChromatecServiceEndpoints.getBackendEndpoints().createUserLink); 
    return await http.post(
      url, 
      headers: {'Content-Type': 'application/json; charset=UTF-8'}, 
      body: jsonEncode(<String, String> {
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'role': role
      })
    )
    .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as Map<String, dynamic>;
        var isCreated = data["isCreated"];
        return isCreated;
      } else {
        return false;
      }     
    }).catchError((e) => false);
  }

  @override
  Future<bool> deleteUser(String userId) async {
    var url = Uri.parse(ChromatecServiceEndpoints.getBackendEndpoints().deleteUserLink); 
    return await http.post(
      url, 
      headers: {"Content-Type": "application/json; charset=UTF-8"}, 
      body:
        jsonEncode(<String, String> {
          "userId": userId,
        })      
    )
    .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as Map<String, dynamic>;
        var isDeleted = data["isDeleted"];
        return isDeleted;
      } else {
        return false;
      }     
    }).catchError((e) => false);
  }

  @override
  Future<List<User>> getUsers() async {
    var docs = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).orderBy("lastSeen", descending: true).get();
    return docs.map((doc) => _fromFirebaseSnapshotToUser(doc.map, doc.id)).toList();
  }

  @override
  Future<List<User>> getEmployee() async {
    var docs = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().usersCollectionName).where("role", isEqualTo: _employeeRoleName).get();
    return docs.map((doc) => _fromFirebaseSnapshotToUser(doc.map, doc.id)).toList();
  }

  @override
  Future<List<Project>> getProjects() async {
    var docs = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().responsibilitiesCollectionName).get();
    return docs.map((doc) => _fromFirebaseSnapshotToProject(doc.map, doc.id)).toList();
  }

  @override
  Future<void> updateResponsibilitiesMembersList(String projectId, List<String> members) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().responsibilitiesCollectionName).document(projectId);
    return ref.update({
      "members": members
    });
  }

  @override
  Future<List<RegistrationRequest>> getRegistrationRequests() async {
    var docs = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().registrationRequestsCollectionName)
      .orderBy("status")
      .orderBy("dateTime", descending: true)
      .get();
    return docs
      .map((doc) => _fromFirebaseSnapshotToRegistrationRequest(doc.map, doc.id))
      .where((request) => request.status != RegistrationRequestStatus.Confirmed)
      .toList(); 
  }

  @override
  Future<void> changeRegistrationRequestStatus(String id, RegistrationRequestStatus status) {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().registrationRequestsCollectionName).document(id);
    return ref.update({
      "status": EnumToString.convertToString(status)
    });
  }   

  User _fromFirebaseSnapshotToUser(Map<String, dynamic> data, String id) {
    DateTime lastSeen = data["lastSeen"];
    List serverQuizes = data["quizes"];
    List<String> quizesList = <String>[];
    serverQuizes.forEach((quizId) {
      quizesList.add(quizId);
    });
    return User(id, data["name"], data["surname"],
      data["email"], data["image"], lastSeen, data["role"], quizesList);
  } 

  Project _fromFirebaseSnapshotToProject(Map<String, dynamic> data, String id) {
    var members = data["members"] as List;
    return Project(id: id, name: data["name"], type: data["type"], members: members.map((member) => member.toString()).toList());
  }

  RegistrationRequest _fromFirebaseSnapshotToRegistrationRequest(Map<String, dynamic> data, String id) {
    DateTime dateTime = data["dateTime"];
    var request = RegistrationRequest(
      id: id, 
      email: data["email"], 
      name: data["name"], 
      surname: data["surname"], 
      dateTime: dateTime, 
      status: EnumToString.fromString(RegistrationRequestStatus.values, data["status"]), 
      uploads: CommonFirebaseRemoteDataSource.uploadsFromServer(data["uploads"])
    );
    return request;
  }

     
}

const String _employeeRoleName = "employee";

