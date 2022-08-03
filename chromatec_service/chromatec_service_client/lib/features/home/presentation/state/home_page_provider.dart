import 'package:chromatec_service/features/account/domain/usecases/logout.dart';
import 'package:chromatec_service/features/account/domain/usecases/update_last_seen_date.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class HomePageProvider extends ChangeNotifier {
  final AuthProvider auth;
  final GetUserByIdUseCase getUserByIdUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdateLastSeenDateUseCase updateLastSeenDateUseCase;

  HomePageProvider({@required this.auth, @required this.getUserByIdUseCase, @required this.logoutUseCase, @required this.updateLastSeenDateUseCase});

  void onInit() {
    if (auth.user != null) {
      updateLastSeenDateUseCase(auth.user.uid);
    } 
  }

  Stream<User> getUser(String id) {
    return getUserByIdUseCase.fromStream(id);
  }

  void onLogout(Future<void> onSuccess()) async {
    await logoutUseCase(onSuccess);
  }
}