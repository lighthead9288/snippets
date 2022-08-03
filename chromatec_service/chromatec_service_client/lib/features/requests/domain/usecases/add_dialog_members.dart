import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class AddDialogMembersUseCase {
  final RequestsRepository repository;

  AddDialogMembersUseCase({@required this.repository});

  Future<void> call(List<User> members, String requestId) => repository.addDialogMembers(members, requestId);
}