import 'package:chromatec_admin/features/admin/domain/entities/user_info_changing_status.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/change_user_role.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/delete_user.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class EditUserProvider extends ChangeNotifier {
  final ChangeUserRoleUseCase changeUserRoleUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  EditUserProvider({@required this.changeUserRoleUseCase, @required this.deleteUserUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  String _role = "";
  String get role => _role;
  set role(String value) {
    _role = value;
    notifyListeners();
  }

  void init(User user) {
    _role = (_role.isEmpty) ? user.role : _role;
  }

  Future<void> changeUserRole(User user, void goBack(UserInfoChangingStatus result)) async {
    isLoading = true;
    await changeUserRoleUseCase(user, role);
    isLoading = false;
    goBack(UserInfoChangingStatus.RoleChanged);
  }

  Future<void> onDelete(User user, Future<bool> showDialog(), void goBack(UserInfoChangingStatus result)) async {
    var isConfirmed = await showDialog();
    if (isConfirmed) {
      var result = await _deleteUser(user);
      goBack(result ? UserInfoChangingStatus.Deleted : UserInfoChangingStatus.DeletingError);
    }
  }

  Future<bool> _deleteUser(User user) async {
    isLoading = true;
    bool isDeleted = await deleteUserUseCase(user);
    isLoading = false;
    return isDeleted;
  }

}