import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/library/domain/entities/library.dart';
import 'package:chromatec_service/features/library/domain/repository/library_repository.dart';
import 'package:flutter/widgets.dart';

class LoadLibraryItemsUseCase {
  final LibraryRepository repository;

  LoadLibraryItemsUseCase({@required this.repository});

  Future<List<LibraryItem>> call(BookmarkHolder holder) => repository.loadLibraryItems(holder);
}