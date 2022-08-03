import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/presentation/add_users_to_dialog/state/add_users_to_dialog_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class AddUsersToDialogPage extends StatefulWidget {
  final String requestId;
  final String category;
  final List<User> usersInDialog;

  AddUsersToDialogPage(this.requestId, this.category, this.usersInDialog);

  @override
  State<StatefulWidget> createState() => AddUsersToDialogPageState();
}

class AddUsersToDialogPageState extends State<AddUsersToDialogPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
        create: (_) => di.sl<AddUsersToDialogProvider>(),
        child: Consumer<AddUsersToDialogProvider>(builder: (_, provider, __) {
          var isEmpty = provider.isNoAddedUsers();
          return Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).addUserToDialog),
                actions: [
                  isEmpty
                      ? Container()
                      : Center(
                          child: Text(provider.addedUsers.length.toString(),
                              style: TextStyle(fontSize: 20))),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      if (!isEmpty) {
                        await provider.addDialogMembers(this.widget.requestId);
                        NavigationService.instance.goBack();
                      }
                    },
                  )
                ],
              ),
              body: _usersUI(provider));
        }));
  }

  Widget _usersUI(AddUsersToDialogProvider provider) {
    return FutureBuilder<List<User>>(
      future: provider.getResponsibleUsers(this.widget.category, this.widget.usersInDialog),
      builder: (BuildContext _context, snapshot) {
        if (provider.isError) {
          return FailureWidget(text: S.of(context).dialogMembersListLoadingError);
        }
        if (provider.isTimeoutExpired) {
          return FailureWidget(text: S.of(context).dialogMembersListLoadingTimeoutExpired);
        }                
        if (snapshot.hasData) {
          var users = snapshot.data;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext _context, index) {
              var user = users[index];
              var isUserInTheDialog = provider.isCurUserInDialog(user);
              return ListTile(
                title: Text("${user.name} ${user.surname}"),
                subtitle: Text(UserRoleHelper.getUserRoleLabel(user.role, _context)),
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (user.imageUrl != "")
                              ? NetworkImage(user.imageUrl)
                              : AssetImage("assets/unknown_user.png"))),
                ),
                trailing: IconButton(
                  icon: (!isUserInTheDialog)
                      ? Icon(Icons.person_add)
                      : Icon(Icons.person_add, color: Colors.green),
                  onPressed: () {
                    if (!isUserInTheDialog) {
                      provider.onAddUser(user);
                    } else {
                      provider.onRemoveUser(user);
                    }
                  },
                ),
              );
            },
          );
        } else {
          return LoadingWidget();
        }
      },
    );
  }
}