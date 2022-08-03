import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class ChangeUserRoleUseCase {
  final AdminRepository repository;

  ChangeUserRoleUseCase({@required this.repository});

  Future<void> call(User user, String role) => repository.changeUserRole(user.id, role);
}