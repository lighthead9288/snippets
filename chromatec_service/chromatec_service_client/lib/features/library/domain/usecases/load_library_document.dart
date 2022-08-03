import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/repository/navigator_based_library_repository.dart';
import 'package:flutter/material.dart';

class LoadLibraryDocumentUseCase {
  final NavigatorBasedLibraryRepository repository;

  LoadLibraryDocumentUseCase({@required this.repository});

  Future<LibraryDocument> call(String id) => repository.getDocument(id);
}