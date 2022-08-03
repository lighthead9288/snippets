import 'dart:io';

import 'package:equatable/equatable.dart';

class FileUpload extends Upload {
  FileUpload(String id, File upload, String name, String size, UploadStatus status, UploadType type) : super(id, upload, name, size, status, type);
}

class UrlUpload extends Upload {
  UrlUpload(String id, String upload, String name, String size, UploadStatus status, UploadType type) : super(id, upload, name, size, status, type);

}

abstract class Upload extends Equatable {
  String id;
  dynamic upload;
  String name;
  String size;
  dynamic status;
  dynamic type;

  Upload(this.id, this.upload, this.name, this.size, this.status, this.type);

  @override
  List<Object> get props => [ id, upload, name, size, status, type ];
}

enum UploadStatus {
  None,
  Loading,
  Failed,
  Loaded,
  Cancelled
}

enum UploadType {
  Image,
  Video,
  File
}