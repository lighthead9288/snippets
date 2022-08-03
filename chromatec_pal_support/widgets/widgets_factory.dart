import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:flutter/widgets.dart';

abstract class IWidgetsFactory {
  IMenu createMenu(ConfigurationProvider provider);
  IAppBar createAppBar();
  IVialsUtilAppBar createVialsUtilAppBar();
  IScheduleUtilAppBar createScheduleUtilAppBar();
}

abstract class IMenu {
  Widget render(BuildContext context);
}

abstract class IAppBar {
  PreferredSizeWidget render(String title);
}

abstract class IVialsUtilAppBar {
  PreferredSizeWidget render(List<TrayHolder> trayHolders);
}

abstract class IScheduleUtilAppBar {
  PreferredSizeWidget render(String title);
}