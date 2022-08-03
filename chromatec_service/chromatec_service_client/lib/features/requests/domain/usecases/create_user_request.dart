import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class CreateUserRequestUseCase {
  final RequestsRepository repository;

  CreateUserRequestUseCase({@required this.repository});

  Future<String> call(UserRequest request) async {
    return await repository.createRequest(request);
  }

}