import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:flutter/foundation.dart';

class UpdateResponsibilityMembersListUsecase {
  final AdminRepository repository;

  UpdateResponsibilityMembersListUsecase({@required this.repository});

  Future<void> call(String projectId, List<String> members) => repository.updateResponsibilitiesMembersList(projectId, members);
}