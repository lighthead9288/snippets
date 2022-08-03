import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

class SupportSubject extends Equatable {
  final String label;
  final List<User> users;

  SupportSubject(this.label, this.users);

  @override
  List<Object> get props => [label, users];
}