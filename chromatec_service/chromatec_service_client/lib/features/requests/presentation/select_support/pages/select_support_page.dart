import 'package:chromatec_service/features/requests/presentation/select_support/state/select_support_provider.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/widgets/select_support_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class SelectSupportPage extends StatefulWidget {
  final String category;

  SelectSupportPage(this.category);

  @override
  State<StatefulWidget> createState() => SelectSupportPageState();
}

class SelectSupportPageState extends State<SelectSupportPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectSupportProvider>(
      create: (_) => di.sl<SelectSupportProvider>(),
      child: Consumer<SelectSupportProvider>(
        builder: (_, provider, __) {
          return Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).selectSupportSubject),
              ),
              body: ModalProgressHUD(
                  inAsyncCall: provider.isLoading,
                  child: SelectSupportWidget(provider: provider, category: this.widget.category),
                )
          );
        }
      )
    );
  }
}
