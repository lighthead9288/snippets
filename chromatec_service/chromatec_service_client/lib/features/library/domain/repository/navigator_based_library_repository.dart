import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';

abstract class NavigatorBasedLibraryRepository {
  Future<LibraryMenu> getLibraryMenu();
  Future<LibraryDocument> getDocument(String id);
  Future<List<LibraryDocument>> getLibraryDocuments();
}