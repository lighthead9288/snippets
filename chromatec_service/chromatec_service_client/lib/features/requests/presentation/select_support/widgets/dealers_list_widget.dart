import 'package:chromatec_service/features/requests/domain/entities/support_subject.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/state/select_support_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DealersListWidget extends StatelessWidget {
  final SelectSupportProvider provider;

  DealersListWidget({@required this.provider});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
        future: provider.getDealers(
          () {
            SnackBarService.instance.showSnackBarError(S.of(context).dealersListLoadingTimeoutExpired);
          },
          () {
            SnackBarService.instance.showSnackBarError(S.of(context).dealersListLoadingError);
          }),
        builder: (BuildContext _context, snapshot) {
          if (snapshot.hasData) {
            var dealers = snapshot.data;
            return ListView.builder(
                itemCount: dealers.length,
                itemBuilder: (BuildContext _context, index) {
                  var curDealer = dealers[index];
                  var name = "${curDealer.name} ${curDealer.surname}";
                  return ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (curDealer.imageUrl != "")
                                  ? NetworkImage(curDealer.imageUrl)
                                  : AssetImage("assets/dealer.png"))),
                    ),
                    title: Text(name),
                    subtitle: Text("${curDealer.email}"),
                    onTap: () => NavigationService.instance.goBack(result: SupportSubject(name, [curDealer])),
                  );
                });
          } else {
            return LoadingWidget();
          }
        });
  }

}