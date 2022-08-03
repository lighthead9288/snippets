import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:chromatec_admin/widgets/windows/windows_add_list_button.dart';
import 'package:chromatec_admin/widgets/windows/windows_app_bar.dart';
import 'package:chromatec_admin/widgets/windows/windows_start_menu.dart';
import 'package:flutter/foundation.dart';

class WindowsControlsFactory extends ChangeNotifier implements IWidgetsFactory {
  @override
  IAddListButton createAddListButton() {
    return WindowsAddListButton();
  }

  @override
  IAppBar createAppBar() {
    return WindowsAppBar();
  }

  @override
  IMenu createMenu() {
    return WindowsStartMenu();
  }

}