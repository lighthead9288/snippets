import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/library/data/datasources/remote_library_datasource.dart';
import 'package:chromatec_service/features/library/domain/entities/library.dart';
import 'package:chromatec_service/features/library/domain/repository/library_repository.dart';
import 'package:flutter/widgets.dart';

class LibraryRepositoryImpl extends LibraryRepository {
  final LibraryRemoteDatasource remoteDatasource;

  LibraryRepositoryImpl({@required this.remoteDatasource});

  @override
  Future<List<LibraryItem>> loadLibraryItems(BookmarkHolder holder) => remoteDatasource.loadLibraryItems(holder);
}