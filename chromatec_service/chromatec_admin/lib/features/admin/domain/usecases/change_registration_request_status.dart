import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class ChangeRegistrationRequestStatusUsecase {
  final AdminRepository repository;

  ChangeRegistrationRequestStatusUsecase({@required this.repository});

  Future<void> call(String id, RegistrationRequestStatus status) => repository.changeRegistrationRequestStatus(id, status); 
}