import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/state/select_support_provider.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/widgets/dealers_list_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class SelectSupportWidget extends StatelessWidget {
  final String category;
  final SelectSupportProvider provider;

  SelectSupportWidget({@required this.category, @required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[200], width: 2)),
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/logo_2.jpg"))),
                    ),
                    title: Text(S.of(context).sdoChromatec),
                    subtitle: Text(SelectSupportProvider.chromatecEmailLabel),
                    onTap: () {
                      provider.getChromatecSupportSubjects(category, S.of(context).sdoChromatec, (result) {
                        NavigationService.instance.goBack(result: result);
                        return;
                      });
                    },
                  )),              
              StreamBuilder<String>(
                stream: provider.getUserRole(),
                builder: (BuildContext _context, snapshot) {
                  if (provider.isError) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: FailureWidget(text: S.of(context).dealersListLoadingError)
                    );
                  }
                  if (snapshot.hasData) {
                    var role = snapshot.data;
                    if (!provider.isUserDealer(role)) {
                      return Expanded(child: DealersListWidget(provider: provider));
                    } else {
                      return Container();
                    }
                  } else {
                    return LoadingWidget();
                  }
                }
              )              
            ],
          ),
        );
  }
}