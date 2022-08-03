import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class GetUsersUseCase {
  final AdminRepository repository;

  GetUsersUseCase({@required this.repository});

  Future<List<User>> call() => repository.getUsers();
}