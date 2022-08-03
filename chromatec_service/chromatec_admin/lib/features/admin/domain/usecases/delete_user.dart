import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class DeleteUserUseCase {
  final AdminRepository repository;

  DeleteUserUseCase({@required this.repository});

  Future<bool> call(User user) {
    return repository.deleteUser(user.id);    
  }
}