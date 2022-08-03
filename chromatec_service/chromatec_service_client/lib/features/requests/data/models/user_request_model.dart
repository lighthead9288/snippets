import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:core/core.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:sembast/timestamp.dart';

class UserRequestModel extends UserRequest {
  UserRequestModel(
      {@required String id,
      @required String ownerId,
      @required String title,
      @required String description,
      @required DateTime dateTime,
      @required String theme,
      @required String status,
      @required bool isPublished,
      @required List<Upload> uploads,
      @required List members,
      @required List<Message> messages})
      : super(id: id, ownerId: ownerId, title: title, description: description, dateTime: dateTime, theme: theme, status: status, isPublished: isPublished,
        uploads: uploads, members: members, messages: messages);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDateTime(dateTime),
      'theme': theme,
      'status': status,
      'isPublished': isPublished,
      'uploads': uploads
          .map((_upload) => DbUpload(
                  id: _upload.id,
                  upload: _upload.upload,
                  name: _upload.name,
                  size: _upload.size,
                  status: _upload.status,
                  type: _upload.type)
              .toJson())
          .toList(),
      'members': members.map((member) => member.toString()).toList(),
      'messages': this.messages
          .map((message) => MessageImplDb(
                  id: message.id,
                  senderId: message.senderId,
                  dateTime: dateTime,
                  text: message.text,
                  uploads: message.uploads)
              .toJson())
          .toList()
    };
  }

  factory UserRequestModel.fromJson(Map<String, dynamic> json) {
    var timestamp = json['dateTime'] as Timestamp;
    return UserRequestModel(
        id: json['id'],
        ownerId: json['ownerId'],
        title: json['title'],
        description: json['description'],
        theme: json['theme'],
        dateTime: timestamp.toDateTime(),
        status: json['status'],
        isPublished: json['isPublished'],
        uploads: json['uploads']
            .map((upload) => DbUpload.fromJson(upload))
            .toList()
            .cast<Upload>(),
        members: json['members'].map((member) => member.toString()).toList(),
        messages: json['messages']
            .map((message) => MessageImplDb.fromJson(message))
            .toList()
            .cast<Message>());
  }
}

class DbUpload extends Upload with EquatableMixin {
  DbUpload(
      {@required String id,
      @required String upload,
      @required String name,
      @required String size,
      @required UploadStatus status,
      @required UploadType type})
      : super(id, upload, name, size, status, type);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'upload': upload,
      'name': name,
      'size': size,
      'status': EnumToString.convertToString(status),
      'type': EnumToString.convertToString(type)
    };
  }

  factory DbUpload.fromJson(Map<String, dynamic> json) {
    return DbUpload(
        id: json['id'],
        upload: json['upload'],
        name: json['name'],
        size: json['size'],
        status: EnumToString.fromString(UploadStatus.values, json['status']),
        type: EnumToString.fromString(UploadType.values, json['type']));
  }

  @override
  List<Object> get props => [ id, upload, name, size, status, type ];
}

class MessageImplDb extends Message {
  MessageImplDb(
      {@required String id,
      @required String senderId,
      @required String text,
      @required List<Upload> uploads,
      @required DateTime dateTime})
      : super(
            id: id,
            senderId: senderId,
            text: text,
            uploads: uploads,
            dateTime: dateTime);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'uploads': uploads
          .map((_upload) => DbUpload(
                  id: _upload.id,
                  upload: _upload.upload,
                  name: _upload.name,
                  size: _upload.size,
                  status: _upload.status,
                  type: _upload.type)
              .toJson())
          .toList(),
      'dateTime': Timestamp.fromDateTime(dateTime)
    };
  }

  factory MessageImplDb.fromJson(Map<String, dynamic> json) {
    var timestamp = json['dateTime'] as Timestamp;
    return MessageImplDb(
        id: json['id'],
        senderId: json['senderId'],
        text: json['text'],
        uploads: json['uploads']
            .map((upload) => DbUpload.fromJson(upload))
            .toList()
            .cast<Upload>(),
        dateTime: timestamp.toDateTime());
  }  
}
