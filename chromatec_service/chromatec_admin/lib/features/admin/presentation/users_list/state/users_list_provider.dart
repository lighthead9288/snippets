import 'dart:async';
import 'package:chromatec_admin/features/admin/domain/entities/user_info_changing_status.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_users.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class UsersListProvider extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase; 

  UsersListProvider({@required this.getUsersUseCase});

  Future<List<User>> getUsers() => getUsersUseCase();

  Future<void> onAddUser(Future<dynamic> Function() goToCredentialsEditor) async {
    var result = await goToCredentialsEditor();
    if (result != null) {
      notifyListeners();
    }
  }

  Future<void> onSelectUser(
    User user, 
    Future<UserInfoChangingStatus> Function() showUserInfoEditor, 
    void Function(UserInfoChangingStatus status) showUserInfoChangingStatus
  ) async {
    var result = await showUserInfoEditor();
    if (result != null) {
      showUserInfoChangingStatus(result);
      notifyListeners();
    }
  }
}