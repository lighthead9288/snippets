import 'package:chromatec_service/features/library/domain/entities/library_element.dart';
import 'package:flutter/material.dart';

class LibraryDocument extends LibraryElement {
  final String url;
  final String keywords;
  final String title;
  final List<LibraryDocumentMenuItem> menuItems;
  final List<LibraryDocumentLink> links;

  LibraryDocument({
    String id,
    String locale,
    String hash,
    DateTime date,
    this.url,
    this.keywords,
    this.title,
    this.menuItems,
    this.links
  }): super(id: id, locale: locale, hash: hash, date: date);  
}

class LibraryDocumentMenuItem {
  final String id;
  final String title;

  LibraryDocumentMenuItem({@required this.id, @required this.title});
}

class LibraryDocumentLink {
  final String id;
  final String title;

  LibraryDocumentLink({@required this.id, @required this.title});
}

