import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WindowsAppBar implements IAppBar {
  @override
  PreferredSizeWidget render(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(title)
    );
  }

}