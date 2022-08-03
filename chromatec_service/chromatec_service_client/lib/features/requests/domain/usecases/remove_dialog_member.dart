import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class RemoveDialogMemberUseCase {
  final RequestsRepository repository;

  RemoveDialogMemberUseCase({@required this.repository});

  Future<void> call(User user, String requestId) => repository.removeDialogMember(user, requestId);
}