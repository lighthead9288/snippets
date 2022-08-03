import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class UpdateUserRequestUseCase {
  final RequestsRepository repository;

  UpdateUserRequestUseCase({@required this.repository});

  Future<void> call(UserRequest request) async {
    return await repository.updateRequest(request);
  }

}