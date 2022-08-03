import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class GetResponsibleUsersUseCase {
  final RequestsRepository repository;

  GetResponsibleUsersUseCase({@required this.repository});

  Future<List<User>> call(String category) => repository.getResponsibleUsers(category);
}