import 'package:chromatec_admin/features/admin/domain/usecases/get_employee.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/update_responsibility_members_list.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class AddEmployeeToResponsibilitiesListProvider extends ChangeNotifier {
  final GetEmployeeUsecase getEmployeeUsecase;
  final UpdateResponsibilityMembersListUsecase updateResponsibilityMembersListUsecase;
  List<String> members = [];

  AddEmployeeToResponsibilitiesListProvider({@required this.getEmployeeUsecase, @required this.updateResponsibilityMembersListUsecase});

  void initMembers(List<String> members) => this.members = members;

  Future<List<User>> getResponsibleUsers() async {
    return getEmployeeUsecase();
  }

  bool containsUser(User user) => members.contains(user.id);

  Future<void> onAddMember(String projectId, String member) async {
    if (!members.contains(member)) {
      members.add(member);
    }
    await updateResponsibilityMembersListUsecase(projectId, members);
    notifyListeners();
  }

  Future<void> onRemoveMember(String projectId, String member) async {
    if (members.contains(member)) {
      members.remove(member);
    }
    await updateResponsibilityMembersListUsecase(projectId, members);
    notifyListeners();
  }
}