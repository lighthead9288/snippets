import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:chromatec_admin/features/admin/presentation/add_employee_to_responsibilities_list/widgets/add_employee_to_responsibilities_list_page.dart';
import 'package:chromatec_admin/features/admin/presentation/projects/state/projects_provider.dart';
import 'package:core/core.dart';
import 'package:core/i18n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;
import 'package:provider/provider.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({ Key key }) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ChangeNotifierProvider<ProjectsProvider>(
        create: (_) => di.sl<ProjectsProvider>(),
        child: Consumer<ProjectsProvider>(
          builder: (_, provider, __) => _ui(provider),
        )
      ),
    );
  }

  Widget _ui(ProjectsProvider provider) {
    return FutureBuilder<List<Project>>(
      initialData: const [],
      future: provider.getProjects(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var projects = snapshot.data;
          return _projectsList(projects);
        } else {
          return LoadingWidget();
        }
      }
    );
  }

  Widget _projectsList(List<Project> projects) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (_, index) {
        var project = projects[index];
        return Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: _deviceHeight * 0.1,
            child: ListTile(
              leading: _getRequestTypeIcon(project.type),
              title: Text(project.name),
              trailing: IconButton(
                icon: const Icon(Icons.add_box_rounded),
                onPressed: () {
                  NavigationService.instance.navigateToRoute(
                    MaterialPageRoute(
                      builder: (_) => AddEmployeeToResponsibilitiesListPage(project: project)
                    )
                  );
                }
              ),
              onTap: () {
                NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(
                    builder: (_) => AddEmployeeToResponsibilitiesListPage(project: project)
                  )
                );
              },
            ),
          )
        );
      }
    );
  }

  Widget _getRequestTypeIcon(String type) {
    switch (type) {
      case "Soft":
        return Image.asset('assets/software.png');
      case "Hardware":
        return Image.asset('assets/hardware.png');
      default:
        return Image.asset('assets/unknown.png');
    }
  }
}