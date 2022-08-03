import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:flutter/widgets.dart';

class CreateUserUseCase {
  final AdminRepository repository;

  CreateUserUseCase({@required this.repository});

  Future<bool> call(String email, String password, String name, String surname, String role) => repository.createUser(email, password, name, surname, role); 
}