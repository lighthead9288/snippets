import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_library_items.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_navigator_based_library_items.dart';
import 'package:chromatec_service/features/library/domain/usecases/search_library_documents.dart';
import 'package:chromatec_service/services/network_connection_service.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class LibraryProvider extends ChangeNotifier with BookmarkHolder {
  final LoadLibraryItemsUseCase loadLibraryItemsUseCase;
  final LoadNavigatorBasedLibraryMenuUseCase loadNavigatorBasedLibraryMenu;
  final CloudStorageService cloudStorageService;
  final NetworkConnectionService networkConnectionService;
  final SearchLibraryDocumentsUsecase searchLibraryDocumentsUsecase;

  bool isFailure = false;
  bool isOffline = false;
  List<LibraryDocument> documents = [];

  LibraryProvider({
    @required this.loadLibraryItemsUseCase, 
    @required this.loadNavigatorBasedLibraryMenu, 
    @required this.cloudStorageService,
    @required this.networkConnectionService,
    @required this.searchLibraryDocumentsUsecase
  });

  Future<LibraryMenu> loadLibraryMenu() async {
    try {
      isOffline = await networkConnectionService.isOffline;
      documents = await searchLibraryDocumentsUsecase();
      return await loadNavigatorBasedLibraryMenu();
    } catch(e) {
      isFailure = true;
      return Future.value(LibraryMenu(id: "", date: DateTime.now(), hash: "", locale: "", sections: []));
    }    
  } 
}