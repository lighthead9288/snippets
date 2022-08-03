import 'package:chromatec_service/features/requests/domain/usecases/get_dialog_members.dart';
import 'package:chromatec_service/features/requests/domain/usecases/remove_dialog_member.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class DialogMembersProvider extends ChangeNotifier {
  final AuthProvider auth;
  final GetUserByIdUseCase getUserByIdUseCase;
  final GetDialogMembersUseCase getDialogMembersUseCase;
  final RemoveDialogMemberUseCase removeDialogMemberUseCase;
  bool isError = false;
  bool isTimeoutExpired = false;

  DialogMembersProvider({@required this.auth, @required this.getUserByIdUseCase, @required this.getDialogMembersUseCase, @required this.removeDialogMemberUseCase});

  Stream<String> getUserRole() {
    try {
      return getUserByIdUseCase.fromStream(auth.user.uid).map((user) => user.role);
    } catch(e) {
      isError = true;
      return Stream.value("");
    }
    
  }

  Future<List<User>> getDialogMembers(String requestId) {
    try {
      return getDialogMembersUseCase(requestId).timeout(Duration(seconds: 60), onTimeout: () {
        isTimeoutExpired = true;
        return Future.value([]);
    }); 
    } catch(e) {
      isError = true;
      return Future.value([]);
    }
  }

  Future<void> removeDialogMember(User user, String requestId) async {
    await removeDialogMemberUseCase(user, requestId);
    notifyListeners();
  }

  bool isMe(String userId) => userId == auth.user.uid;

  bool canUserChangeDialogMembersList(String role) => role != "user"; 

}