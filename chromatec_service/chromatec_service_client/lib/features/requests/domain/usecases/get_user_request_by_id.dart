import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class GetUserRequestByIdUseCase {
  final RequestsRepository repository;

  GetUserRequestByIdUseCase({@required this.repository});

  Future<UserRequest> call(String id) => repository.getUserRequestById(id);
}