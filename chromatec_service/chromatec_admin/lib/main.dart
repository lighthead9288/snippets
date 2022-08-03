import 'dart:io';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:core/core.dart';
import 'package:core/flavors/flavors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firedart/firedart.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String projectId = "chromatecservice-e6dbe";
  if (Platform.isWindows) {
    Firestore.initialize(projectId);
  } else {
    await Firebase.initializeApp();
  }
  await di.init();
  ChromatecServiceEndpoints.setFlavor(Flavors.Prod);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MaterialColor primaryColor = const MaterialColor(0xFF90CAF9, <int, Color>{
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF2196F3),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: (ChromatecServiceEndpoints.currentFlavor == Flavors.Test),
        theme: ThemeData(
            primaryColor: Colors.blue[200],
            colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryColor)
                .copyWith(secondary: Colors.blue[200]),
            scaffoldBackgroundColor: Colors.white,
            backgroundColor: Colors.white),
        home: ChangeNotifierProvider<IWidgetsFactory>(
          create: (_) => di.sl<IWidgetsFactory>(),
          child: Consumer<IWidgetsFactory>(
            builder: (_, widgetsFactory, __) => widgetsFactory.createMenu().render(context),
          ),
        ),
        navigatorKey: NavigationService.instance.navigatorKey,
        locale: Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        }
      );
  }
}