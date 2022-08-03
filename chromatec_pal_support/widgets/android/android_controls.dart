import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/widgets/android/android_app_bar.dart';
import 'package:chromatec_pal_support/widgets/android/android_schedule_util_app_bar.dart';
import 'package:chromatec_pal_support/widgets/android/android_start_menu.dart';
import 'package:chromatec_pal_support/widgets/android/android_vials_util_app_bar.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';

class AndroidControlsFactory implements IWidgetsFactory {

  @override
  IAppBar createAppBar() {
    return AndroidAppBar();
  }

  @override
  IMenu createMenu(ConfigurationProvider provider) {
    return AndroidStartMenu(provider: provider);
  }

  @override
  IVialsUtilAppBar createVialsUtilAppBar() {
    return AndroidVialsUtilAppBar();
  }

  @override
  IScheduleUtilAppBar createScheduleUtilAppBar() {
    return AndroidScheduleUtilAppBar();
  }
} 