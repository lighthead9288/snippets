import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:flutter/foundation.dart';

class GetProjectsUsecase {
  final AdminRepository repository;

  GetProjectsUsecase({@required this.repository});

  Future<List<Project>> call() => repository.getProjects();
}