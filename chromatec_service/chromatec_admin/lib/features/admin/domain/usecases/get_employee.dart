import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class GetEmployeeUsecase {
  final AdminRepository repository;

  GetEmployeeUsecase({@required this.repository});

  Future<List<User>> call() => repository.getEmployee();
}