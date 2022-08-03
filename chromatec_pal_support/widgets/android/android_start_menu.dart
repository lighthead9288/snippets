import 'dart:io';

import 'package:chromatec_pal_support/pages/connection/connection_page.dart';
import 'package:chromatec_pal_support/pages/library/library_page.dart';
import 'package:chromatec_pal_support/pages/utils_list/utils_page.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/services/navigation_service.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';

class AndroidStartMenu implements IMenu {
  final ConfigurationProvider provider;

  AndroidStartMenu({required this.provider});

  @override
  Widget render(BuildContext context) {
    return AndroidAppStartMenuPage(provider: provider);
  }
}

class AndroidAppStartMenuPage extends StatefulWidget {
  final ConfigurationProvider provider;

  const AndroidAppStartMenuPage({required this.provider,  Key? key }) : super(key: key);

  @override
  State<AndroidAppStartMenuPage> createState() => _AndroidAppStartMenuPageState();
}

class _AndroidAppStartMenuPageState extends State<AndroidAppStartMenuPage> {
  
  int _curItemIndex = 0;
  final List<Widget> _items = [
    LibraryPage(),
    UtilsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      //  title: (!Platform.isWindows) ? const Text("Chromatec PAL support"): const Text(""),
        title: const Text("Chromatec PAL support"),
        actions: [
          Container(
            child: Text(
              widget.provider.modulesSource, 
              style: const TextStyle(fontSize: 20)
            ), 
            alignment: Alignment.center, 
            margin: const EdgeInsets.only(right: 35)
          ),
          PopupMenuButton(
              icon: const Icon(Icons.cable),            
              itemBuilder: (_) {
                return [
                  PopupMenuItem(
                    child: GestureDetector(
                      child: Row(
                        children: const [
                          Icon(Icons.lan), 
                          Text('Device')],
                      ),
                      onTap: () {
                        NavigationService.instance.goBack();
                        showDialog(context: context, builder: (_) => ConnectionPage(provider: widget.provider));
                      },
                    )
                  ),
                  PopupMenuItem(
                    child: GestureDetector(
                      child: Row(
                        children: const [
                          Icon(Icons.file_open), 
                          Text('Configuration file')
                        ],
                      ),
                      onTap: () {
                        NavigationService.instance.goBack();
                        widget.provider.onPickConfig();
                      },
                    )
                  )
                ];
              }
            )
        ],
      ),
      body: Center(
        child: _items[_curItemIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Library'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_sharp),
            label: 'Utils'
          ),
        ],
        currentIndex: _curItemIndex,
        onTap: (index) {
          setState(() {
            _curItemIndex = index;
          });
        },
      ),
    );
  }
}