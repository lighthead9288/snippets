import 'package:flutter/widgets.dart';

abstract class IWidgetsFactory extends ChangeNotifier{
  IMenu createMenu();
  IAppBar createAppBar();
  IAddListButton createAddListButton();
}

abstract class IMenu {
  Widget render(BuildContext context);
}

abstract class IAppBar {
  Widget render(String title);
}

abstract class IAddListButton {
  Widget render(void onTap());
}