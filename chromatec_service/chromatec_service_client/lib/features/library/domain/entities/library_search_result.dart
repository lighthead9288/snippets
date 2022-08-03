import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class LibrarySearchResult {
  final LibraryDocument document;
  final List<String> results;
  bool titleContains = false;

  LibrarySearchResult({@required this.document, @required this.results, this.titleContains});
}