import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';

class AndroidScheduleUtilAppBar implements IScheduleUtilAppBar {
  @override
  PreferredSizeWidget render(String title) {
    return AppBar(
        title: Text(title),
        leading: Builder(builder: (_context) {
          final ScaffoldState? scaffold = Scaffold.maybeOf(_context);
          final ModalRoute<dynamic>? parentRoute = ModalRoute.of(_context);
          final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
          final bool canPop = parentRoute?.canPop ?? false;
          if (hasEndDrawer && canPop) {
            return const BackButton();
          } else {
            return Container();
          }
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
              icon: const Icon(Icons.settings)
            )
          )
        ],
      );
  }

}