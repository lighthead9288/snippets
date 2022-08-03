import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class GetDealersListUseCase {
  final RequestsRepository repository;

  GetDealersListUseCase({@required this.repository});

  Future<List<User>> call() => repository.getDealers();
}