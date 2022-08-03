import 'dart:io';
import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage _storage;
  Reference _baseRef;
  var _uuid = Uuid();
  String _profileImages = ChromatecServiceEndpoints.getFileStorageEndpoints().profileImagesFolderName;
  String _user_uploads = ChromatecServiceEndpoints.getFileStorageEndpoints().userUploadsFolderName;
  String _files = "files";
  String _photos = "photos";
  String _videos = "videos";
  String _registration_requests = ChromatecServiceEndpoints.getFileStorageEndpoints().registrationRequestsFolderName;  

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<String> uploadUserProfileImage(String uid, File image) async {
    try {
      var snapshot = await _baseRef.child(_profileImages).child(uid).putFile(image);
      var url = await snapshot.ref.getDownloadURL();
      return url;
    } catch(e) {
    }
  }

  Future<String> uploadRegistrationRequestFile(String email, File file) async {
    try {
      var snapshot = await _baseRef.child(_registration_requests).child(email).child("${path.basenameWithoutExtension(file.path)}-${_uuid.v1()}").putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      return url;
    } catch(e) {
    }
  }

  UploadTask uploadUserFile(String uid, File file) {
    try {
      return  _baseRef.child(_user_uploads).child(uid).child(_files).child("${path.basenameWithoutExtension(file.path)}-${_uuid.v1()}").putFile(file);
    } catch(e) {
      print(e);
    }
  }

  UploadTask uploadUserImage(String uid, File image) {
    try {
      return _baseRef.child(_user_uploads).child(uid).child(_photos).child("${path.basenameWithoutExtension(image.path)}-${_uuid.v1()}").putFile(image);
    } catch(e) {
    }
  }

  UploadTask uploadUserVideo(String uid, File video) {
    try {
      return _baseRef.child(_user_uploads).child(uid).child(_videos).child("${path.basenameWithoutExtension(video.path)}-${_uuid.v1()}").putFile(video);
    } catch(e) {
    }
  }

  Future<void> downloadFile(Upload upload, String resultFilePath, void onReceiveProgress(int count, int total)) async {
    return downloadFileByUrl(upload.upload, resultFilePath, onReceiveProgress);
  }

  Future<void> downloadFileByUrl(String url, String resultFilePath, void onReceiveProgress(int count, int total)) async {
    Dio dio = Dio();
    return await dio.download(url, resultFilePath, onReceiveProgress: onReceiveProgress);
  }
}
