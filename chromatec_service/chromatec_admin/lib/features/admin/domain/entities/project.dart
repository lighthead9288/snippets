import 'package:flutter/foundation.dart';

class Project {
  final String id;
  final String name;
  final String type;
  final List<String> members;

  Project({@required this.id, @required this.name, @required this.type, this.members = const []});
}