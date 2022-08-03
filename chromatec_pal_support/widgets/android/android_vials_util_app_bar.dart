import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';

class AndroidVialsUtilAppBar implements IVialsUtilAppBar {
  @override
  PreferredSizeWidget render(List<TrayHolder> trayHolders) {
    return AppBar(
      title: const Text('Vials'),
      bottom: (trayHolders.isNotEmpty) 
        ? TabBar(
            tabs: trayHolders.map((trayHolder) => Tab(child: Text(trayHolder.name))).toList()
          )
        : null
    );
  }
}