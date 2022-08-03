import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';

class AndroidAppBar implements IAppBar {
  @override
  PreferredSizeWidget render(String title) {
    return AppBar(
      title: Text(title)
    );
  }

}