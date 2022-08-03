import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class UserRoleHelper {
  static String getUserRoleLabel(String role, BuildContext context) {
    switch (role) {
      case "user": return S.of(context).user;
      case "dealer": return S.of(context).dealer;
      case "employee": return S.of(context).employee;
      case "admin": return S.of(context).admin;
    }
  }
}

