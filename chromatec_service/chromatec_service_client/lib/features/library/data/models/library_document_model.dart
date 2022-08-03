import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/timestamp.dart';

class LibraryDocumentModel extends LibraryDocument {
  LibraryDocumentModel({
    @required String id,
    @required String locale,
    @required String hash,
    @required DateTime date,
    @required String url,
    @required String keywords,
    @required String title,
    @required List<LibraryDocumentMenuItem> menuItems,
    @required List<LibraryDocumentLink> links
  }): super(
    id: id, 
    locale: locale, 
    hash: hash, 
    date: date, 
    url:url, 
    keywords: keywords, 
    title: title, 
    menuItems: menuItems, 
    links: links
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locale': locale,
      'hash': hash,
      'date': Timestamp.fromDateTime(date),
      'url': url,
      'keywords': keywords,
      'title': title,
      'menuItems': menuItems.map((item) => LibraryDocumentMenuItemModel(id: item.id, title: item.title).toJson()).toList(),
      'links': links.map((link) => LibraryDocumentLinkModel(id: link.id, title: link.title).toJson()).toList()
    };
  }

  factory LibraryDocumentModel.fromJson(Map<String, dynamic> json) {
    Timestamp timestamp = json['date'];
    DateTime date = timestamp.toDateTime();
    List menuItems = json['menuItems'];
    List links = json['links'];
    return LibraryDocumentModel(
      date: date,
      locale: json['locale'],
      hash: json['hash'],
      keywords: json['keywords'],
      url: json['url'],
      title: json['title'],
      id: json['id'],
      menuItems: menuItems.map((item) => LibraryDocumentMenuItemModel.fromJson(item)).toList(),
      links: links.map((item) => LibraryDocumentLinkModel.fromJson(item)).toList()
    );
  }
}

class LibraryDocumentMenuItemModel extends LibraryDocumentMenuItem {
  LibraryDocumentMenuItemModel({@required String id, @required String title}): super(id: id, title: title);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title
    };
  }

  factory LibraryDocumentMenuItemModel.fromJson(Map<String, dynamic> json) => LibraryDocumentMenuItemModel(id: json["id"], title: json["title"]);
}

class LibraryDocumentLinkModel extends LibraryDocumentLink {
  LibraryDocumentLinkModel({@required String id, @required String title}): super(id: id, title: title);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title
    };
  }

  factory LibraryDocumentLinkModel.fromJson(Map<String, dynamic> json) => LibraryDocumentLinkModel(id: json["id"], title: json["title"]);
}