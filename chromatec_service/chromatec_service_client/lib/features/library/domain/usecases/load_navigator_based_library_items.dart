import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/domain/repository/navigator_based_library_repository.dart';
import 'package:flutter/material.dart';

class LoadNavigatorBasedLibraryMenuUseCase {
  final NavigatorBasedLibraryRepository repository;

  LoadNavigatorBasedLibraryMenuUseCase({@required this.repository});

  Future<LibraryMenu> call() => repository.getLibraryMenu();

}