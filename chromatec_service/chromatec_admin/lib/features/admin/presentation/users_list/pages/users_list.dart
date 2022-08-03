import 'package:chromatec_admin/features/admin/domain/entities/user_info_changing_status.dart';
import 'package:chromatec_admin/features/admin/presentation/create_user/widgets/create_user_widget.dart';
import 'package:chromatec_admin/features/admin/presentation/edit_user_info/widgets/user_info_widget.dart';
import 'package:chromatec_admin/features/admin/presentation/users_list/state/users_list_provider.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;

class UsersListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    SnackBarService.instance.buildContext = context;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersListProvider>(
          create: (_) => di.sl<UsersListProvider>()
        ),
        ChangeNotifierProvider<IWidgetsFactory>(
          create: (_) => di.sl<IWidgetsFactory>()
        )
      ],
      child: Consumer2<UsersListProvider, IWidgetsFactory>(
        builder: (_, provider, widgetsFactory, __) {
          return Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => di.sl<UsersListProvider>(),
              child: Consumer<UsersListProvider>(builder: (_, provider, __) {
                return _adminPageUI(provider);
              }),
            ),
            floatingActionButton: widgetsFactory.createAddListButton().render(() async {
              await provider.onAddUser(() => NavigationService.instance.navigateToRoute(
                MaterialPageRoute(builder: (_) => CreateUserWidget())
              ));
            }),
          );
        },
      )
    );
  }

  Widget _adminPageUI(UsersListProvider provider) {
    return FutureBuilder<List<User>>(
        initialData: const [],
        future: provider.getUsers(),
        builder: (_context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var users = snapshot.data;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext _context, int index) {
                  var user = users[index];
                  return Card(
                    child: ListTile(
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
                      subtitle: Text(UserRoleHelper.getUserRoleLabel(user.role, context)),
                      onTap: () async {
                        await provider.onSelectUser(
                          user, 
                          () => showModalBottomSheet<UserInfoChangingStatus>(context: context, builder: (_) => UserInfoWidget(user: user)), 
                          (status) => _showProfileChangingStatus(status)
                        );               
                      },
                    ),
                  );
                });
          } else {
            return Center(child: LoadingWidget());
          }
        });
  }

  void _showProfileChangingStatus(UserInfoChangingStatus status) {
    switch(status) {      
      case UserInfoChangingStatus.RoleChanged:
        SnackBarService.instance.showSnackBarSuccess(S.of(context).usersRoleWasUpdated);
        break;
      case UserInfoChangingStatus.Deleted:
        SnackBarService.instance.showSnackBarSuccess(S.of(context).userWasDeleted);
        break;
      case UserInfoChangingStatus.DeletingError:
        SnackBarService.instance.showSnackBarError(S.of(context).cannotDeleteUser);
        break;
    } 
  }
}


