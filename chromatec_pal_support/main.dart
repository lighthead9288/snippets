import 'dart:io';

import 'package:chromatec_pal_support/services/navigation_service.dart';
import 'package:chromatec_pal_support/pages/library/library_page.dart';
import 'package:chromatec_pal_support/pages/utils_list/utils_page.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String projectId = "chromatecpalsupport";
  if (Platform.isWindows) {
    print('Windows app is running');
    Firestore.initialize(projectId);
  } else {
    print('Mobile app is running');
    await Firebase.initializeApp();
  }  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  MaterialColor primaryColor = const MaterialColor(
    0xFF90CAF9, 
    <int, Color>{
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
    }
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      navigatorKey: NavigationService.instance.navigatorKey,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _curItemIndex = 0;
  final List<Widget> _items = [
    LibraryPage(),
    UtilsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConfigurationProvider>.value(
      value: ConfigurationProvider.instance,
      child: Consumer<ConfigurationProvider>(builder: (_, provider, __) {
        var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
        return _ui(provider, widgetsFactory);
      }),
    );
  }

  Widget _ui(ConfigurationProvider provider, IWidgetsFactory widgetsFactory) {
    return widgetsFactory.createMenu(provider).render(context);
  }
}