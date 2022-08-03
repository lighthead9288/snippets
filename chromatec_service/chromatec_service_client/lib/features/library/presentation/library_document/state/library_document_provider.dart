import 'dart:async';

import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_library_document.dart';
import 'package:chromatec_service/services/network_connection_service.dart';
import 'package:flutter/foundation.dart';

class LibraryDocumentProvider extends ChangeNotifier {
  final LoadLibraryDocumentUseCase loadLibraryDocumentUseCase;
  final NetworkConnectionService networkConnectionService;
  
  bool isError = false;
  bool isOffline = false;
  String documentId = "";
  StreamController<bool> documentLoadingStreamController;
  StreamController<bool> searchResultsNavigationStreamController;
  Stream<bool> documentLoadingStream;
  Stream<bool> searchResultsNavigationStream;  
  int searchResultsLength = 0;
  int curSearchResultNumber = 0;

  LibraryDocumentProvider({@required this.loadLibraryDocumentUseCase, @required this.networkConnectionService});

  Future<LibraryDocument> loadLibraryDocument(String id) async {
    isOffline = await networkConnectionService.isOffline;

    if (documentId == "") {
      documentId = id;
    }

    // Set loading indication while loading from db
    documentLoadingStreamController = StreamController<bool>();
    documentLoadingStream = documentLoadingStreamController.stream;

    searchResultsNavigationStreamController = StreamController<bool>();
    searchResultsNavigationStream = searchResultsNavigationStreamController.stream;
    documentLoadingStreamController.add(true);
    searchResultsNavigationStreamController.add(false);
    try {
      var doc = await loadLibraryDocumentUseCase(documentId);
      if (doc != null) {
        return doc;
      } else {
        isError = true;
        return Future.value(LibraryDocument());
      }      
    } catch(e) {
      isError = true;
      return Future.value(LibraryDocument());
    } 
  }
  

  void onDocumentLoadingFinished() {
    documentLoadingStreamController.add(false);
  }

  void onLinkTap(String id) {
    documentId = id;
    notifyListeners();
  }

  void onSearchResultsLengthInit(int length) {
    if (length > 0) {
      searchResultsLength = length;
      searchResultsNavigationStreamController.add(true);
    }    
  }

  String getSearchResultsString(List<String> results) {
    if (results.isEmpty) {
      return "[]";
    }
    results = results.toSet().toList();
    String resultString = "[";
    for(var i = 0; i < results.length; i++) {
      resultString += "'" + results[i] + ((i != results.length - 1) ? "'," : "'];");
    }
    return resultString;
  }

  int onSearchResultsDown() {
    if (curSearchResultNumber == searchResultsLength - 1) {
      curSearchResultNumber = 0;
    } else {
      curSearchResultNumber++;
    }
    searchResultsNavigationStreamController.add(true);
    return curSearchResultNumber;
  }

  int onSearchResultsUp() {
    if (curSearchResultNumber == 0) {
      curSearchResultNumber = searchResultsLength - 1;
    } else {
      curSearchResultNumber--;
    }
    searchResultsNavigationStreamController.add(true);
    return curSearchResultNumber;
  }


}