import 'package:chromatec_service/features/requests/presentation/requests_list/widgets/requests_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class RequestsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RequestsPageState();
}

class RequestsPageState extends State<RequestsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<RequestsListProvider>(),
      child: Consumer<RequestsListProvider>(
        builder: (_, provider, __) {
          return RequestsListWidget(provider: provider);
        }
      )
    );
  } 
}





