import 'package:chromatec_service/features/library/data/datasources/local_navigator_based_library_datasource.dart';
import 'package:chromatec_service/features/library/data/datasources/remote_navigator_based_library_datasource.dart';
import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/domain/repository/navigator_based_library_repository.dart';
import 'package:chromatec_service/services/network_connection_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigatorBasedLibraryRepositoryImpl extends NavigatorBasedLibraryRepository {
  final RemoteNavigatorBasedLibraryDatasource remoteDatasource;
  final LocalNavigatorBasedLibraryDatasource localDatasource;
  final NetworkConnectionService networkConnectionService;  

  NavigatorBasedLibraryRepositoryImpl({@required this.remoteDatasource, @required this.localDatasource, @required this.networkConnectionService});

  @override
  Future<LibraryMenu> getLibraryMenu() async {
    if (!await networkConnectionService.isOffline) {
      var menu = await remoteDatasource.getLibraryMenu();
      localDatasource.saveLibraryMenu(menu);
      return menu;
    } else {
      return await localDatasource.getLibraryMenu();
    }    
  }

  @override
  Future<LibraryDocument> getDocument(String id) async {
    if (!await networkConnectionService.isOffline) {
      var document = await remoteDatasource.getDocument(id);
      localDatasource.saveLibraryDocument(document);    
      
      // Загрузка всех документов, связанных с выбранным 
      document.links.forEach((link) {
        remoteDatasource.getDocument(link.id).then((doc) => localDatasource.saveLibraryDocument(doc));
      });

      return document;
    } else {
      return await localDatasource.getLibraryDocument(id);
    }    
  }

  @override
  Future<List<LibraryDocument>> getLibraryDocuments() async {
    if (! await networkConnectionService.isOffline) {
      return await remoteDatasource.getLibraryDocuments();
    } else {
      return await localDatasource.getLibraryDocuments();
    }
  }
}