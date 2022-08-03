import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_app_bar.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_schedule_util_app_bar.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_start_menu.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_vials_util_app_bar.dart';

class WindowsControlsFactory implements IWidgetsFactory {

  @override
  IAppBar createAppBar() {
    return WindowsAppBar();
  }

  @override
  IMenu createMenu(ConfigurationProvider provider) {
    return WindowsStartMenu(provider: provider);
  }

  @override
  IVialsUtilAppBar createVialsUtilAppBar() {
    return WindowsVialsUtilAppBar();
  }

  @override
  IScheduleUtilAppBar createScheduleUtilAppBar() {
    return WindowsScheduleUtilAppBar();
  }

}