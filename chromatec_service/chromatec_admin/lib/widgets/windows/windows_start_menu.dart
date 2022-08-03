import 'package:chromatec_admin/features/admin/presentation/projects/widgets/projects_page.dart';
import 'package:chromatec_admin/features/admin/presentation/registration_requests/widgets/registration_requests_page.dart';
import 'package:chromatec_admin/features/admin/presentation/users_list/pages/users_list.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class WindowsStartMenu implements IMenu {

  @override
  Widget render(BuildContext context) {
    return WindowsAppStartMenuPage();
  }
}

class WindowsAppStartMenuPage extends StatefulWidget {
  const WindowsAppStartMenuPage({ Key key }) : super(key: key);

  @override
  State<WindowsAppStartMenuPage> createState() => _WindowsAppStartMenuPageState();
}

class _WindowsAppStartMenuPageState extends State<WindowsAppStartMenuPage> {
  int _index = 0;

  final _menuItems = [ UsersListPage(), RegistrationRequestsPage(), ProjectsPage() ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).adminPanel), backgroundColor: Colors.white),
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
            NavigationRailDestination(icon: const Icon(Icons.people), label: Text(S.of(context).usersList)),
            NavigationRailDestination(icon: const Icon(Icons.app_registration), label: Text(S.of(context).registrationRequests)),
            NavigationRailDestination(icon: const Icon(Icons.work), label: Text(S.of(context).projects)),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _menuItems[_index])
      ],
    )
    );
  }
}