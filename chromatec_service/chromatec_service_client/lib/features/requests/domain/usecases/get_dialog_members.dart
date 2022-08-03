import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class GetDialogMembersUseCase {
  final RequestsRepository repository;

  GetDialogMembersUseCase({@required this.repository});

  Future<List<User>> call(String requestId) => repository.getDialogMembers(requestId);
} 