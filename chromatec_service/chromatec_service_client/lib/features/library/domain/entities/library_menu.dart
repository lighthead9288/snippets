import 'package:chromatec_service/features/library/domain/entities/library_element.dart';
import 'package:flutter/material.dart';

class LibraryMenu extends LibraryElement {
  final List<LibraryMenuSection> sections;

  LibraryMenu({@required String id, @required String locale, @required String hash, @required DateTime date, @required this.sections})
  : super(id: id, locale: locale, hash: hash, date: date);
}

class LibraryMenuSection {
  final String name;
  final List<LibraryMenuChapter> chapters;

  LibraryMenuSection({@required this.name, @required this.chapters});
}

class LibraryMenuChapter {
  final String name;
  final List<LibraryMenuLink> links;

  LibraryMenuChapter({@required this.name, @required this.links});
}

class LibraryMenuLink {
  final String id;
  final String title;

  LibraryMenuLink({@required this.id, @required this.title});
}