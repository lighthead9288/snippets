import 'package:chromatec_admin/features/admin/presentation/create_user/state/create_user_page_provider.dart';
import 'package:chromatec_admin/widgets/select_user_role_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;
import 'package:provider/provider.dart';

class CreateUserWidget extends StatefulWidget {
  @override
  State<CreateUserWidget> createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => di.sl<CreateUserPageProvider>(),
      child: Consumer<CreateUserPageProvider>(
        builder: (_, provider, __) => Scaffold(
          body: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: _deviceHeight * 0.1),
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SelectUserRoleWidget(role: provider.role, onChanged: (value) => provider.role = value, isExpanded: true),
                        UserRegisterFormWidget(
                          provider: provider,
                          isLoading: provider.isLoading, 
                          onRegisterSuccess: () async  => NavigationService.instance.goBack(result: true), 
                          onRegisterError: () async => SnackBarService.instance.showSnackBarError(S.of(context).registeringError)
                        ),
                        const SizedBox(
                          height: 10
                        ),
                        _goBack()
                  ]))),
        )
      ),
    );
  }

  Widget _goBack() {
    return GestureDetector(
        onTap: () {
          NavigationService.instance.goBack();
        },
        child: Container(
            height: 50,
            width: _deviceWidth,
            child: Icon(Icons.arrow_back, size: 40)));
  }
}