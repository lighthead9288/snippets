import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:chromatec_admin/features/admin/presentation/add_employee_to_responsibilities_list/state/add_employee_to_responsibilities_list_provider.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;
import 'package:provider/provider.dart';

class AddEmployeeToResponsibilitiesListPage extends StatefulWidget {
  final Project project;

  const AddEmployeeToResponsibilitiesListPage({ Key key, @required this.project }) : super(key: key);

  @override
  State<AddEmployeeToResponsibilitiesListPage> createState() => _AddEmployeeToResponsibilitiesListPageState();
}

class _AddEmployeeToResponsibilitiesListPageState extends State<AddEmployeeToResponsibilitiesListPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddEmployeeToResponsibilitiesListProvider>(
          create: (_) => di.sl<AddEmployeeToResponsibilitiesListProvider>()
        ),
        ChangeNotifierProvider<IWidgetsFactory>(
          create: (_) => di.sl<IWidgetsFactory>()
        )
      ],
      child: Consumer2<AddEmployeeToResponsibilitiesListProvider, IWidgetsFactory>(
        builder: (_, provider, widgetsFactory, __) {
          provider.initMembers(widget.project.members);
            return Scaffold(
              appBar: widgetsFactory.createAppBar().render(widget.project.name),
              body: _ui(provider)
            );
        }
      ),
    );
  }

  Widget _ui(AddEmployeeToResponsibilitiesListProvider provider) {
    return FutureBuilder<List<User>>(
      initialData: const [],
      future: provider.getResponsibleUsers(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var users = snapshot.data;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: ((context, index) {
              var user = users[index];
              return _userCard(user, provider);
            })
          );
        } else {
          return LoadingWidget();
        }
      }
    );
  }

  Widget _userCard(User user, AddEmployeeToResponsibilitiesListProvider provider) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: ((user.imageUrl != "")
              ? NetworkImage(user.imageUrl)
              : const AssetImage("assets/unknown_user.png")) as ImageProvider
            )                          
        ),
      ),
      title: Text("${user.name} ${user.surname}"),
      subtitle: Text(user.email),
      trailing: Checkbox(
        value: provider.containsUser(user),
        onChanged: (value) async {
          if (value) {
            await provider.onAddMember(widget.project.id, user.id);
          } else {
            await provider.onRemoveMember(widget.project.id, user.id);
          }
        },
      ),
    );
  }

}