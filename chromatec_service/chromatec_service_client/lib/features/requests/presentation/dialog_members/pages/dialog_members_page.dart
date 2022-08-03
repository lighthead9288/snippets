import 'package:chromatec_service/features/requests/presentation/dialog_members/state/dialog_members_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog_members/widgets/dialog_members_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class DialogMembersPage extends StatefulWidget {
  final String requestId;
  final String theme;

  DialogMembersPage(this.requestId, this.theme);

  @override
  State<StatefulWidget> createState() => DialogMembersPageState();
}

class DialogMembersPageState extends State<DialogMembersPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).dialogMembers)),
        body: ChangeNotifierProvider(
            create: (_) => di.sl<DialogMembersProvider>(),
            child: Consumer<DialogMembersProvider>(
                builder: (_, provider, __) => _membersUI(provider)
            )
          )
        );
  }

  Widget _membersUI(DialogMembersProvider provider) {
    return StreamBuilder<String>(
      stream: provider.getUserRole(),
      builder: (BuildContext _context, snapshot) {
        if (snapshot.hasData) {
          var role = snapshot.data;
          return DialogMembersWidget(provider: provider, requestId: this.widget.requestId, theme: this.widget.theme, userRole: role);
        } else {
          return LoadingWidget();
        }
      },
    );
  }
}
