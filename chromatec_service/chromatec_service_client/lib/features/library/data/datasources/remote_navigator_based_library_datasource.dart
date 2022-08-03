import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

abstract class RemoteNavigatorBasedLibraryDatasource {
  Future<LibraryMenu> getLibraryMenu();
  Future<LibraryDocument> getDocument(String id);
  Future<List<LibraryDocument>> getLibraryDocuments();
}

class RemoteNavigatorBasedLibraryDatasourceImpl extends RemoteNavigatorBasedLibraryDatasource {
  static const String _libraryMenuDocumentId = "_library";

  final FirebaseFirestore db;

  RemoteNavigatorBasedLibraryDatasourceImpl({@required this.db});

  @override
  Future<LibraryMenu> getLibraryMenu() async {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().libraryReportsCollectionName).doc(_libraryMenuDocumentId);
    return await ref.get().then((snapshot) => _fromFirebaseSnapshotToLibraryMenu(snapshot));
  }

  @override
  Future<LibraryDocument> getDocument(String id) async {
    var ref = db.collection(ChromatecServiceEndpoints.getDbEndpoints().libraryReportsCollectionName).doc(id);
    return await ref.get().then((snapshot) => _fromFirebaseSnapshotToLibraryDocument(snapshot));
  }

  @override
  Future<List<LibraryDocument>> getLibraryDocuments() async {
    var ref = await db.collection(ChromatecServiceEndpoints.getDbEndpoints().libraryReportsCollectionName).where("id", isNotEqualTo: _libraryMenuDocumentId).get();
    return Future.wait(ref.docs.map((snapshot) {
      return snapshot.reference.get().then((documentSnapshot) => _fromFirebaseSnapshotToLibraryDocument(snapshot));
    }));
  }



  LibraryDocument _fromFirebaseSnapshotToLibraryDocument(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    Timestamp timestamp = data()["date"];
    DateTime date = timestamp.toDate();
    String locale = data()["locale"];
    String hash = data()["hash"];
    String keywords = data()["keywords"];
    String url = data()["url"];
    String title = data()["title"];
    String id = snapshot.id;
    List menuItemsList = data()["menuItems"];
    var menuItems = menuItemsList.map((item) {
      var menuItem = item as Map<String, dynamic>;
      var id = menuItem["id"];
      var title = menuItem["title"];
      return LibraryDocumentMenuItem(id: id, title: title);
    }).toList();
    List linksItems = data()["links"];
    var links = linksItems.map((item) {
      var link = item as Map<String, dynamic>;
      var id = link["id"];
      var title = link["title"];
      return LibraryDocumentLink(id: id, title: title);
    }).where((link) => link.id != "_library").toList();
    return LibraryDocument(
      locale: locale, 
      hash: hash, 
      date: date, 
      url: url,
      title: title,
      id: id, 
      keywords: keywords, 
      menuItems: menuItems, 
      links: links
    );
  }

  LibraryMenu _fromFirebaseSnapshotToLibraryMenu(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    Timestamp timestamp = data()["date"];
    DateTime date = timestamp.toDate();
    String locale = data()["locale"];
    String hash = data()["hash"];
    List sections = data()["sections"];
    String id = snapshot.id;
    var libraryMenuSections = sections.map((sectionsItem) {
      var section = sectionsItem as Map<String, dynamic>;      
      var name = section["name"];
      List chapters = section["chapters"];
      var libraryMenuChapters = chapters.map((chaptersItem) {
        var chapter = chaptersItem as Map<String, dynamic>;
        var name = chapter["name"];
        List links = chapter["links"];
        var libraryMenuLinks = links.map((linksItem) {
          var link = linksItem as Map<String, dynamic>;
          var id = link["id"];
          var title = link["title"];
          return LibraryMenuLink(id: id, title: title);
        }).toList();
        return LibraryMenuChapter(name: name, links: libraryMenuLinks);
      }).toList();
      return LibraryMenuSection(name: name, chapters: libraryMenuChapters);
    }).toList();
    return LibraryMenu(id: id, locale: locale, hash: hash, date: date, sections: libraryMenuSections);
  }   
}