import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static PermissionService instance = PermissionService();

  Future<PermissionStatus> askExtDataWritePermissions() async {
    PermissionStatus permissionStatus = await _getPermission(PermissionGroup.storage);
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
    }
    return permissionStatus;
  }

  Future<PermissionStatus> askContactPermissions() async {
    PermissionStatus permissionStatus = await _getPermission(PermissionGroup.contacts);
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
    }
    return permissionStatus;
  }

  Future<PermissionStatus> _getPermission(PermissionGroup group) async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(group);
    print(permission);
    if (permission != PermissionStatus.granted 
      &&
        permission != PermissionStatus.unknown
        ) 
        {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([group]);
      return permissionStatus[group] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      print('Permission is denied');
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Permission denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.unknown) {
        print('Permission is disabled');
        throw PlatformException(
            code: "PERMISSION_DISABLED",
            message: "Permission is disabled on device",
            details: null);
    }
  }


}