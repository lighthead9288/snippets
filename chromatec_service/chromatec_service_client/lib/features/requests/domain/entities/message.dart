import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final List<Upload> uploads;
  final DateTime dateTime;

  Message({this.id, this.senderId, this.text, this.uploads, this.dateTime});

  @override
  List<Object> get props => [ id, senderId, text, uploads, dateTime ];
}
