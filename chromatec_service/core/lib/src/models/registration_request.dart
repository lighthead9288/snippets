import 'package:core/src/models/upload.dart';
import 'package:flutter/foundation.dart';

class RegistrationRequest {
  final String email;
  final String name;
  final String surname;
  final DateTime dateTime;
  final RegistrationRequestStatus status;
  String id;
  List<Upload> uploads;

  RegistrationRequest({
    @required this.email, 
    @required this.name, 
    @required this.surname, 
    @required this.dateTime, 
    @required this.status,
    this.id = "",
    this.uploads = const []
  });
}

enum RegistrationRequestStatus {
  Sent,
  Confirmed,
  Rejected
}