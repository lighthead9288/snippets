import 'package:chromatec_service/features/requests/domain/entities/support_subject.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_dealers_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_responsible_users.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class SelectSupportProvider extends ChangeNotifier {
  final AuthProvider auth;
  final GetUserByIdUseCase getUserByIdUseCase;
  final GetDealersListUseCase getDealersListUseCase;
  final GetResponsibleUsersUseCase getResponsibleUsersUseCase;

  bool isLoading = false;
  bool isError = false;
  String selectedSupportSubject = "";
  static const String chromatecEmailLabel = "32@chromatec.ru";
  static const String userRoleDealer = "dealer";

  SelectSupportProvider({@required this.auth, @required this.getUserByIdUseCase, @required this.getDealersListUseCase, @required this.getResponsibleUsersUseCase});

  Stream<String> getUserRole() {
    try {
      return getUserByIdUseCase.fromStream(auth.user.uid).map((user) => user.role);
    } catch(e) {
      isError = true;
      return Stream.value("");
    }
    
  }

  Future<List<User>> getDealers(void onTimeoutExpired(), void onError()) {
    try {
      return getDealersListUseCase().timeout(Duration(seconds: 60), onTimeout: () {
        onTimeoutExpired();
        return Future.value([]);
      });
    } catch(e) {
      onError();
      return Future.value([]);
    }
    
  }

  void getChromatecSupportSubjects(String category, String chromatecLabel, Function goBack(SupportSubject subject)) async {
    isLoading = true;
    notifyListeners();
    var chromatecSupportSubjects = await getResponsibleUsersUseCase(category);
    isLoading = false;
    notifyListeners();
    goBack(SupportSubject(chromatecLabel, chromatecSupportSubjects));
  }

  bool isUserDealer(String role) => role == userRoleDealer;
}