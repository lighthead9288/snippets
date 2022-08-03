import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class WindowsAppBar implements IAppBar {
  @override
  Widget render(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(title)
    );
  }

}