import 'dart:async';
import 'package:chromatec_admin/features/admin/domain/usecases/create_user.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class CreateUserPageProvider extends ChangeNotifier with CreateUserProvider {
  final CreateUserUseCase createUserUseCase;

  CreateUserPageProvider({@required this.createUserUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  String _role = "user";
  String get role => _role;
  set role(String value) {
    _role = value;
    notifyListeners();
  }

  @override
  void onCreateUser(Future<void> Function() onSuccess, Future<void> Function() onError) async {
    isLoading = true;
    var result = await createUserUseCase(email, password, name, surname, role);
    if (result) {
      onSuccess();
    } else {
      onError();
    }
    isLoading = false;    
  }

}