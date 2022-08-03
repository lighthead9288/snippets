import 'package:chromatec_service/features/home/presentation/state/home_page_provider.dart';
import 'package:chromatec_service/features/home/presentation/widgets/home_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            ChangeNotifierProvider<HomePageProvider>(
              create: (_) => di.sl<HomePageProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: di.sl.get<AuthProvider>()
            )
          ],
          child: Consumer2<HomePageProvider, AuthProvider>(
            builder: (_, provider, auth, __) {
              return HomePageWidget(provider: provider, auth: auth);
            }
          )
        );
  }
}
