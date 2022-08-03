import 'dart:io';

import 'package:chromatec_admin/features/admin/presentation/projects/widgets/projects_page.dart';
import 'package:chromatec_admin/features/admin/presentation/registration_requests/widgets/registration_requests_page.dart';
import 'package:chromatec_admin/features/admin/presentation/users_list/pages/users_list.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AndroidStartMenu implements IMenu {
  @override
  Widget render(BuildContext context) {
    return AndroidAppStartMenuPage();
  }
}

class AndroidAppStartMenuPage extends StatelessWidget {
  const AndroidAppStartMenuPage({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).adminPanel),
              bottom: TabBar(
                isScrollable: !Platform.isWindows,
                tabs: [
                  Tab(
                      icon: const Icon(Icons.people),
                      child: Text(S.of(context).usersList)),
                  Tab(
                      icon: const Icon(Icons.app_registration),
                      child: Container(
                          child: Text(S.of(context).registrationRequests))),
                  Tab(
                      icon: const Icon(Icons.work),
                      child: Text(S.of(context).projects)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                UsersListPage(),
                RegistrationRequestsPage(),
                ProjectsPage()
              ],
            )));
  }
}