import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/state/request_editor_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ExitDialogWidget extends StatelessWidget {
  final String requestId;
  final RequestEditorProvider provider;
  final bool Function(RequestEditorProvider provider) onValidate;

  ExitDialogWidget(
      {@required this.provider,
      @required this.requestId,
      @required this.onValidate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(S.of(context).doYouWantToExitFromRequestEditing),
        actions: <Widget>[
          TextButton(
            onPressed: () => NavigationService.instance.goBack(result: false),
            child: Text(S.of(context).cancel, style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              NavigationService.instance.goBack(result: true);
            },
            child: Text(S.of(context).exit, style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              NavigationService.instance.goBack(result: false);
              provider.onSave(requestId, () {
                NavigationService.instance
                    .goBack(result: RequestSavingResult.Saved);
              }, () {
                NavigationService.instance
                    .goBack(result: RequestSavingResult.TimeoutExpired);
              }, () {
                NavigationService.instance
                    .goBack(result: RequestSavingResult.Error);
              });
            },
            child: Text(S.of(context).save, style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              NavigationService.instance.goBack(result: false);
              var _isValid = onValidate(provider);
              if (_isValid) {
                provider.onPublish(requestId, () {
                  NavigationService.instance
                      .goBack(result: RequestSavingResult.Published);
                }, () {
                  NavigationService.instance
                      .goBack(result: RequestSavingResult.TimeoutExpired);
                }, () {
                  NavigationService.instance
                      .goBack(result: RequestSavingResult.Error);
                });
              }
            },
            child: Text(S.of(context).publish, style: TextStyle(fontSize: 11)),
          )
        ]);
  }
}