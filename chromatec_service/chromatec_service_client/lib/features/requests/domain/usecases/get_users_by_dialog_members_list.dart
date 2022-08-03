import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class GetUsersByDialogMembersListUseCase {
  final RequestsRepository repository;

  GetUsersByDialogMembersListUseCase({@required this.repository});

  Future<List<User>> call(List members) => repository.getUsersByDialogMembersList(members);
}