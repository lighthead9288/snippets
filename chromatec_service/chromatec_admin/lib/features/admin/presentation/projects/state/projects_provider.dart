import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_projects.dart';
import 'package:flutter/foundation.dart';

class ProjectsProvider extends ChangeNotifier {
  final GetProjectsUsecase getProjectsUsecase;

  ProjectsProvider({@required this.getProjectsUsecase});

  Future<List<Project>> getProjects() => getProjectsUsecase();
}