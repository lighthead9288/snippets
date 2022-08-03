import 'package:chromatec_service/features/requests/presentation/request_editor/state/request_editor_provider.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/widgets/request_editor_widget.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;

class RequestEditorPage extends StatefulWidget {
  String requestId;

  RequestEditorPage();

  RequestEditorPage.setRequestId(String id) {
    requestId = id;
  }

  @override
  State<StatefulWidget> createState() => _RequestEditorPageState();
}

class _RequestEditorPageState extends State<RequestEditorPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<RequestEditorProvider>()
        ),
        ChangeNotifierProvider.value(
          value: di.sl.get<TasksProvider>()
        )
      ],
      child: Consumer2<RequestEditorProvider, TasksProvider>(
        builder: (_, provider, tasksProvider, __) => RequestEditorWidget(provider: provider, requestId: this.widget.requestId)
      ),
    );
  }
}
