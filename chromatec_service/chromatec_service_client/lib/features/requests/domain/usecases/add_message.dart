import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class AddMessageUseCase {
  final RequestsRepository repository;

  AddMessageUseCase({@required this.repository});

  Future<void> call(String requestId, Message message) {
    return repository.addMessage(requestId, message);
  }
}