import 'package:flutter/foundation.dart';

abstract class LibraryElement {
  final String id;
  final String locale;
  final String hash;
  final DateTime date;

  LibraryElement({@required this.id, @required this.locale, @required this.hash, @required this.date});
}