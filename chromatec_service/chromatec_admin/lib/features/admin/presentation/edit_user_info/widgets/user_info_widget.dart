import 'dart:io';

import 'package:chromatec_admin/features/admin/presentation/edit_user_info/state/edit_user_provider.dart';
import 'package:chromatec_admin/widgets/select_user_role_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;

class UserInfoWidget extends StatefulWidget {
  final User user;

  UserInfoWidget({@required this.user});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  double _deviceHeight;
  double _deviceWidth;
  
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    SnackBarService.instance.buildContext = context;

    return ChangeNotifierProvider(
      create: (_) => di.sl<EditUserProvider>(),
      child: Consumer<EditUserProvider>(
        builder: (_, provider, __) {
          provider.init(widget.user);
          return SizedBox(
            height: _deviceHeight * 0.45,
            child: (!provider.isLoading) 
              ? SingleChildScrollView(
                  child: Column(
                    children: _getItems(provider),
                  )
                )
              : const Center(child: CircularProgressIndicator())
          );
        }
      ),
    );
  }

  List<Widget> _getItems(EditUserProvider provider) {
    var imageRadius = (Platform.isWindows) ? 150.0 :_deviceWidth * 0.4;
    return [
      Container(
            margin: const EdgeInsets.all(10),
            width: imageRadius,
            height: imageRadius,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(imageRadius),
              image: DecorationImage(
                image: ((widget.user.imageUrl != "") ? NetworkImage(widget.user.imageUrl): const AssetImage("assets/unknown_user.png")) as ImageProvider,
                fit: BoxFit.cover
              )
            ),
          ),
          Text("${widget.user.name} ${widget.user.surname}", style: const TextStyle(fontSize: 25)),
          SelectUserRoleWidget(role: provider.role, onChanged: (value) => provider.role = value, isExpanded: false),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,            
            children: [
              ElevatedButton(
                onPressed: () async {
                  await provider.changeUserRole(widget.user, (result) {
                    NavigationService.instance.goBack(result: result);
                  });                  
                }, 
                child: Container(
                  alignment: Alignment.center,
                  child: Text(S.of(context).save), 
                  width: 80
                )
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () async {
                  await provider.onDelete(
                    widget.user, 
                    () {
                          return showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(S.of(context).deletingUserConfirmationLabel),
                            actions: [
                              TextButton(
                                onPressed: () => NavigationService.instance.goBack(result: false),
                                child: Text(S.of(context).cancel)
                              ),
                              TextButton(
                                onPressed: () async => NavigationService.instance.goBack(result: true),
                                child: Text(S.of(context).delete)
                              ),
                            ]
                          ));
                      }, 
                    (result) { 
                      NavigationService.instance.goBack(result: result);
                    });
                },              
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.red),                  
                ), 
                child: Container(
                  alignment: Alignment.center,
                  child: Text(S.of(context).delete), 
                  width: 80
                )
              )
            ],
          )
    ];
  }
}