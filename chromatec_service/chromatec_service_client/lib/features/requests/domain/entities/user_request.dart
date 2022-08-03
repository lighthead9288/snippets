import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

class UserRequest extends Equatable {
  final String id;
  final String ownerId;
  final DateTime dateTime;
  final DateTime createdAt;
  final String title;
  final String description;
  final String theme;
  final String status;
  final bool isPublished;
  List members = [];
  List<Upload> uploads = <Upload>[];  
  List<Message> messages = <Message>[];

  UserRequest({this.id, this.ownerId, this.title, this.description, this.dateTime, this.createdAt, this.theme, this.status, this.isPublished, this.uploads, this.members, this.messages});

  @override
  List<Object> get props => [ id, ownerId, dateTime, createdAt, title, description, theme, status, isPublished, members, uploads, messages];

}

enum RequestsFilter {
  Published,
  Saved,
  All
}

enum RequestSavingResult {
  Published,
  Saved,
  Error,
  TimeoutExpired
}