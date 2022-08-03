import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class GetUserByIdUseCase {
  final CommonRepository repository;
  
  GetUserByIdUseCase({@required this.repository});

  Stream<User> fromStream(String id) {
    return repository.getUserStreamById(id);
  }

  Future<User> fromFuture(String id) {
    return repository.getUserById(id);
  }
}