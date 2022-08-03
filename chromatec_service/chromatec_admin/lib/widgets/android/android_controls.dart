import 'package:chromatec_admin/widgets/android/android_add_list_button.dart';
import 'package:chromatec_admin/widgets/android/android_app_bar.dart';
import 'package:chromatec_admin/widgets/android/android_start_menu.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:flutter/foundation.dart';

class AndroidControlsFactory extends ChangeNotifier implements IWidgetsFactory {

  @override
  IAddListButton createAddListButton() {
    return AndroidAddListButton();
  }

  @override
  IAppBar createAppBar() {
    return AndroidAppBar();
  }

  @override
  IMenu createMenu() {
    return AndroidStartMenu();
  }

} 