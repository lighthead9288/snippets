import 'package:chromatec_service/features/library/data/models/library_document_model.dart';
import 'package:chromatec_service/features/library/data/models/library_menu_model.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/services/local_db.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

abstract class LocalNavigatorBasedLibraryDatasource {
  Future<LibraryMenu> getLibraryMenu();
  Future<LibraryDocument> getLibraryDocument(String id);
  Future<List<LibraryDocument>> getLibraryDocuments();
  Future<void> saveLibraryMenu(LibraryMenu menu);
  Future<void> saveLibraryDocument(LibraryDocument document);
}

class LocalNavigatorBasedLibraryDatasourceImpl extends LocalNavigatorBasedLibraryDatasource {
  static const String _libraryBoxName = "Library";
  static const String _libraryDocumentId = "_library";
  final _libraryFolder = intMapStoreFactory.store(_libraryBoxName);
  Future<Database> get _db async => await AppDatabase.instance.database;

  final CloudStorageService cloudStorageService;

  LocalNavigatorBasedLibraryDatasourceImpl({@required this.cloudStorageService});

  @override
  Future<LibraryDocument> getLibraryDocument(String id) async {
    var snapshot = await _libraryFolder.findFirst(await _db, finder: Finder(filter: Filter.equals("id", id)));
    LibraryDocument result;
    if (snapshot!= null) {      
      result = LibraryDocumentModel.fromJson(snapshot.value);
    }
    return result;
  }

  @override
  Future<LibraryMenu> getLibraryMenu() async {
    var snapshot = await _libraryFolder.findFirst(await _db, finder: Finder(filter: Filter.equals("id", _libraryDocumentId)));
    LibraryMenu result;
    if (snapshot!= null) {      
      result = LibraryMenuModel.fromJson(snapshot.value);
    }
    return result; 
  }

  @override
  Future<void> saveLibraryDocument(LibraryDocument document) async { 
    var documentInDb = await getLibraryDocument(document.id);
    if (documentInDb == null) {
      _saveDocumentFile(
        document, 
        (path) { 
          _addLibraryDocument(document, path);
        });      
    } else if (document.hash != documentInDb.hash) {
      _saveDocumentFile(
        document, 
        (path) {
          _updateLibraryDocument(document, path);
        });      
    }
  }

  @override
  Future<void> saveLibraryMenu(LibraryMenu menu) async {
    var menuInDb = await getLibraryMenu();
    if (menuInDb == null) {
      print('Creating menu...');
      _addLibraryMenu(menu);
    } else if (menu.hash != menuInDb.hash) {
      print('Updating menu...');
      _updateLibraryMenu(menu);
    }
  }

  @override
  Future<List<LibraryDocument>> getLibraryDocuments() async {
    var snapshots = await _libraryFolder.find(await _db, finder: Finder(filter: Filter.notEquals("id", _libraryDocumentId)));
    if ((snapshots!= null) && (snapshots.isNotEmpty)) {      
      return snapshots.map((snapshot) => LibraryDocumentModel.fromJson(snapshot.value)).toList();
    } else {
      return [];
    }
  } 
  
  Future<void> _saveDocumentFile(LibraryDocument document, void onFinish(String path)) async {
    var url = document.url;
    var resultFilePath = await FileHelper.getLibraryDocumentDownloadingPath(document.id, document.locale);
    print(resultFilePath);
    print("${document.id} downloading...");
    cloudStorageService.downloadFileByUrl(url, resultFilePath, (count, total) { 
      var downloadingPercent = count / total * 100;
      print("${document.id} - $downloadingPercent");
      if (downloadingPercent == 100) {
        print("Downloading was finished");
        onFinish(resultFilePath);
      }
    });
  }

  Future<void> _addLibraryDocument(LibraryDocument document, String path) async {
    var created = await _libraryFolder.add(
      await _db,
      LibraryDocumentModel(
        id: document.id, 
        locale: document.locale, 
        hash: document.hash, 
        date: document.date, 
        url: path, 
        keywords: document.keywords, 
        title: document.title, 
        menuItems: document.menuItems, 
        links: document.links
      ).toJson()
    );
    print("Created document ${document.id}: $created");
  }

  Future<void> _updateLibraryDocument(LibraryDocument document, String path) async {
    var updated = await _libraryFolder.update(
      await _db,
      LibraryDocumentModel(
        id: document.id, 
        locale: document.locale, 
        hash: document.hash, 
        date: document.date, 
        url: path, 
        keywords: document.keywords, 
        title: document.title, 
        menuItems: document.menuItems, 
        links: document.links
      ).toJson(), 
      finder: Finder(filter: Filter.equals('id', document.id))
    );
    print("Updated document ${document.id}: $updated");
  }

  Future<void> _addLibraryMenu(LibraryMenu menu) async {
    var created = await _libraryFolder.add(
      await _db,
      LibraryMenuModel(
        id: menu.id,
        date: menu.date, 
        hash: menu.hash, 
        locale: menu.locale, 
        sections: menu.sections
      ).toJson()
    );
    print("Created menu: $created");    
  }

  Future<void> _updateLibraryMenu(LibraryMenu menu) async {
    var updated = await _libraryFolder.update(
      await _db,
      LibraryMenuModel(
        id: menu.id,
        date: menu.date, 
        hash: menu.hash, 
        locale: menu.locale, 
        sections: menu.sections
      ).toJson(), 
      finder: Finder(filter: Filter.equals('id', menu.id))
    );
    print("Updated menu: $updated");
  }  
}