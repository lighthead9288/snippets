import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class CommonRepositoryImpl implements CommonRepository {
  final CommonRemoteDataSource remoteDataSource; 

  CommonRepositoryImpl({@required this.remoteDataSource});

  @override
  Stream<User> getUserStreamById(String id) {
    return remoteDataSource.getUserStreamById(id);
  }

  @override
  Future<User> getUserById(String id) {
    return remoteDataSource.getUserFutureById(id);
  }

}