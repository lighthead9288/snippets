import 'dart:core';

import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/widgets/dialog_widget.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:chromatec_service/services/messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class DialogPage extends StatefulWidget {
  final String requestId;
  final String requestTitle;

  DialogPage({@required this.requestId, @required this.requestTitle});

  @override
  State<StatefulWidget> createState() => DialogPageState();
}

class DialogPageState extends State<DialogPage> {

  @override
  Widget build(BuildContext context) {
    MessagingService.currentRequestId = this.widget.requestId;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => di.sl<DialogProvider>(),
          ),
          ChangeNotifierProvider.value(value: di.sl.get<TasksProvider>()),
          ChangeNotifierProvider<DialogButtonProvider>(
            create: (_) => di.sl.get<DialogButtonProvider>()
          )
        ],
        child: Consumer2<DialogProvider, TasksProvider>(
            builder: (_, provider, tasksProvider, __) {
              return DialogWidget(provider: provider, requestId: this.widget.requestId, requestTitle: this.widget.requestTitle);
        }));
  }  
}
