import 'package:chromatec_pal_support/pages/connection/connection_page.dart';
import 'package:chromatec_pal_support/pages/library/library_page.dart';
import 'package:chromatec_pal_support/pages/utils_list/utils_page.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/services/navigation_service.dart';
import 'package:chromatec_pal_support/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';

class WindowsStartMenu implements IMenu {

  final ConfigurationProvider provider;

  WindowsStartMenu({required this.provider});

  @override
  Widget render(BuildContext context) {
    return WindowsAppStartMenuPage(provider: provider);
  }
}

class WindowsAppStartMenuPage extends StatefulWidget {
  final ConfigurationProvider provider;

  const WindowsAppStartMenuPage({ required this.provider, Key? key }) : super(key: key);

  @override
  State<WindowsAppStartMenuPage> createState() => _WindowsAppStartMenuPageState();
}

class _WindowsAppStartMenuPageState extends State<WindowsAppStartMenuPage> {
  int _index = 0;

  final _menuItems = [ LibraryPage(), UtilsPage() ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Row(
      children: [
        NavigationRail(
          selectedIndex: _index,
          onDestinationSelected: (int index) {
              setState(() {
                _index = index;
              });
          },
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(icon: const Icon(Icons.library_books_outlined), label: Text('Library')),
            NavigationRailDestination(icon: const Icon(Icons.science_sharp), label: Text('Utils')),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _menuItems[_index])
      ],
    )
    );
  }
}