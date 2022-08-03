import 'package:core/core.dart';
import 'package:flutter/material.dart';

class SelectUserRoleWidget extends StatelessWidget {
  final String role;
  final Function(dynamic value) onChanged;
  final bool isExpanded;
  static const String _userLabel = "user";
  static const String _dealerLabel = "dealer";
  static const String _employeeLabel = "employee";
  static const String _adminLabel = "admin";

  SelectUserRoleWidget({@required this.role, @required this.onChanged, @required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: [
        DropdownMenuItem(value: _userLabel, child: Text(UserRoleHelper.getUserRoleLabel(_userLabel, context))),
        DropdownMenuItem(value: _dealerLabel, child: Text(UserRoleHelper.getUserRoleLabel(_dealerLabel, context))),
        DropdownMenuItem(value: _employeeLabel, child: Text(UserRoleHelper.getUserRoleLabel(_employeeLabel, context))),
        DropdownMenuItem(value: _adminLabel, child: Text(UserRoleHelper.getUserRoleLabel(_adminLabel, context))),
      ],
      value: role,
      onChanged: (value) => onChanged(value),
      isExpanded: isExpanded,
    );
  }
}
