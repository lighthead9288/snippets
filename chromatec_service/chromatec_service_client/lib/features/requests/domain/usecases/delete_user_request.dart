import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class DeleteUserRequestUsecase {
  final RequestsRepository repository;

  DeleteUserRequestUsecase({@required this.repository});

  Future<void> call(UserRequest request) async {
    return await repository.deleteRequest(request);
  }
}