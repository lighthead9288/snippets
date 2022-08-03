import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/library/domain/entities/library.dart';

abstract class LibraryRepository {
  Future<List<LibraryItem>> loadLibraryItems(BookmarkHolder holder);
}