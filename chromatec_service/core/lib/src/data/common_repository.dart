import 'package:core/core.dart';

abstract class CommonRepository {
  Stream<User> getUserStreamById(String id);
  Future<User> getUserById(String id);
}