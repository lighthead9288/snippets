import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class GetRegistrationRequestsUsecase {
  final AdminRepository repository;

  GetRegistrationRequestsUsecase({@required this.repository});

  Future<List<RegistrationRequest>> call() => repository.getRegistrationRequests();
}