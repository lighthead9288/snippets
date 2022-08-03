import 'package:chromatec_service/features/requests/domain/usecases/add_dialog_members.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_responsible_users.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class AddUsersToDialogProvider extends ChangeNotifier {
  final AuthProvider auth;
  final GetResponsibleUsersUseCase getResponsibleUsersUseCase;
  final AddDialogMembersUseCase addDialogMembersUseCase;
  List<User> addedUsers = <User>[];
  bool isError = false;
  bool isTimeoutExpired = false;

  AddUsersToDialogProvider({@required this.auth, @required this.getResponsibleUsersUseCase, @required this.addDialogMembersUseCase});

  void onAddUser(User user) {
    addedUsers.add(user);
    notifyListeners();
  }

  void onRemoveUser(User user) {
    addedUsers.removeWhere((element) => element.id == user.id);
    notifyListeners();
  }

  bool isNoAddedUsers() => addedUsers.length == 0;

  bool isCurUserInDialog(User user) {
    var addedUserIds = addedUsers.map((e) => e.id).toList();
    return addedUserIds.contains(user.id);
  }

  Future<List<User>> getResponsibleUsers(String category, List<User> _usersInDialog) async {
    try {
      var users = await getResponsibleUsersUseCase(category).timeout(Duration(seconds: 60), onTimeout: () {
        isTimeoutExpired = true;
        return Future.value([]);
    });
      var filteredResponsibleUsers = _removeAlreadyExistingUsers(users, _usersInDialog, auth.user.uid);
      return filteredResponsibleUsers;
    } catch(e) {
      isError = true;
      return Future.value([]);
    }
  }

  Future<void> addDialogMembers(String requestId) async => await addDialogMembersUseCase(addedUsers, requestId);

  List<User> _removeAlreadyExistingUsers(List<User> users, List<User> usersInDialog, String curAuthUserId) {
    List<User> result = <User>[];
    var usersInDialogIds = usersInDialog.map((e) => e.id);
    users.forEach((user) {
      if ((!usersInDialogIds.contains(user.id)) && (user.id != curAuthUserId)) {
        result.add(user);
      }
    });
    return result;
  }

}