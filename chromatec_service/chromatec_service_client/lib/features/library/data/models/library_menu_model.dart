import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/timestamp.dart';

class LibraryMenuModel extends LibraryMenu {
  LibraryMenuModel({
    @required DateTime date, 
    @required String hash, 
    @required String locale, 
    @required List<LibraryMenuSection> sections,
    @required String id
  }): super(id: id, date: date, hash: hash, locale: locale, sections: sections);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDateTime(date),
      'hash': hash,
      'locale': locale,
      'sections': sections.map((section) => 
        LibraryMenuSectionModel(name: section.name, chapters: section.chapters).toJson()
      ).toList()
    };
  }

  factory LibraryMenuModel.fromJson(Map<String, dynamic> json) {
      var timestamp = json['date'] as Timestamp;
      var date = timestamp.toDateTime();
      List sections = json['sections'];
      var libraryMenuSections = sections.map((section) => LibraryMenuSectionModel.fromJson(section)).toList();
      return LibraryMenuModel(date: date, id: json['id'], hash: json['hash'], locale: json['locale'], sections: libraryMenuSections);
  }
}

class LibraryMenuSectionModel extends LibraryMenuSection {
  LibraryMenuSectionModel({@required String name, @required List<LibraryMenuChapter> chapters}) : super(name: name, chapters: chapters);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'chapters': chapters.map((chapter) => 
        LibraryMenuChapterModel(
          name: name, 
          links: chapter.links
        ).toJson()).toList()
    };
  }

  factory LibraryMenuSectionModel.fromJson(Map<String, dynamic> json) {
      var name = json["name"];
      List chapters = json["chapters"];
      return LibraryMenuSectionModel(name: name, chapters: chapters.map((chapter) => LibraryMenuChapterModel.fromJson(chapter)).toList());
  }
}

class LibraryMenuChapterModel extends LibraryMenuChapter {
  LibraryMenuChapterModel({@required String name, @required List<LibraryMenuLink> links}) : super(name: name, links: links);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'links': links.map((link) => LibraryMenuLinkModel(id: link.id, title: link.title).toJson()).toList()
    };
  }

  factory LibraryMenuChapterModel.fromJson(Map<String, dynamic> json) {
      var name = json["name"];
      List links = json["links"];
      return LibraryMenuChapterModel(name: name, links: links.map((link) => LibraryMenuLinkModel.fromJson(link)).toList());
  }
}

class LibraryMenuLinkModel extends LibraryMenuLink {
  LibraryMenuLinkModel({@required String id, @required String title}) : super(id: id, title: title);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title
    };
  }

  factory LibraryMenuLinkModel.fromJson(Map<String, dynamic> json) => LibraryMenuLinkModel(id: json["id"], title: json["title"]);  
}