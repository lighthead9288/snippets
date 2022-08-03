import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/presentation/dialog_members/state/dialog_members_provider.dart';
import 'package:chromatec_service/features/requests/presentation/add_users_to_dialog/pages/add_users_to_dialog_page.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DialogMembersWidget extends StatefulWidget {  
  final DialogMembersProvider provider;
  final String requestId;
  final String theme;
  final String userRole;

  DialogMembersWidget({@required this.provider, @required this.requestId, @required this.theme, @required this.userRole});  

  @override
  State<StatefulWidget> createState() => _DialogMembersWidgetState();
}

class _DialogMembersWidgetState extends State<DialogMembersWidget> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext ctx) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var provider = this.widget.provider;
    return FutureBuilder<List<User>>(
            future: provider.getDialogMembers(this.widget.requestId),
            initialData: <User>[],
            builder: (BuildContext _context, _snapshot) {
              if ((_snapshot.connectionState == ConnectionState.done)) {
                if (provider.isError) {
                  return FailureWidget(text: S.of(context).dialogMembersListLoadingError);
                }
                if (provider.isTimeoutExpired) {
                  return FailureWidget(text: S.of(context).dialogMembersListLoadingTimeoutExpired);
                }
                
                var users = _snapshot.data;
                var canUserChangeDialogMembersList = provider.canUserChangeDialogMembersList(this.widget.userRole);
                return Column(
                  children: [
                    canUserChangeDialogMembersList
                        ? Container(
                            height: 50,
                            width: _deviceWidth,
                            child: ElevatedButton(
                              onPressed: () async {
                                await NavigationService.instance
                                    .navigateToRoute(MaterialPageRoute(
                                        builder: (BuildContext _context) =>
                                            AddUsersToDialogPage(
                                                this.widget.requestId,
                                                this.widget.theme,
                                                users)));
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.person_add),
                                  SizedBox(width: 20),
                                  Text(S.of(context).addDialogMembers)
                                ],
                              ),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            )
                          )
                        : Container(),
                    Expanded(
                        child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext _context, index) {
                        var user = users[index];
                        var isMe = provider.isMe(user.id);
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
                                        : AssetImage(
                                            "assets/unknown_user.png"))),
                          ),
                          trailing: IconButton(
                            icon:
                                ((canUserChangeDialogMembersList) && (!isMe))
                                    ? Icon(Icons.cancel)
                                    : Container(),
                            onPressed: () async => await provider.removeDialogMember(user, this.widget.requestId)
                          ),
                        );
                      },
                    ))
                  ],
                );
              } else {
                return LoadingWidget();
              }
            },
          );
  }

  
}

