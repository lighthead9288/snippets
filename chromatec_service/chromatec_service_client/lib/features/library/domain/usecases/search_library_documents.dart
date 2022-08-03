import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/repository/navigator_based_library_repository.dart';
import 'package:flutter/foundation.dart';

class SearchLibraryDocumentsUsecase {
  final NavigatorBasedLibraryRepository repository;

  SearchLibraryDocumentsUsecase({@required this.repository});

  Future<List<LibraryDocument>> call() async {
    return await repository.getLibraryDocuments();
  }
}