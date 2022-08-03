import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class GetDialogDataUseCase {
  final RequestsRepository repository;

  GetDialogDataUseCase({@required this.repository});

  Stream<UserRequest> call(String requestId) {
    return repository.getUserRequestStreamById(requestId);
  }
}