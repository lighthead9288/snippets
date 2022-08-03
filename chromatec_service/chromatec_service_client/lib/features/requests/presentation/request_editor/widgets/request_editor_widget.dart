import 'package:chromatec_service/common/widgets/pick_uploads_widget.dart';
import 'package:chromatec_service/common/widgets/vertical_attachments_list.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/state/request_editor_provider.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/widgets/exit_dialog_widget.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/pages/select_support_page.dart';
import 'package:core/core.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RequestEditorWidget extends StatefulWidget {
  final String requestId;
  final RequestEditorProvider provider;

  RequestEditorWidget({@required this.provider, @required this.requestId});

  @override
  State<StatefulWidget> createState() => _RequestEditorWidgetState();
}

class _RequestEditorWidgetState extends State<RequestEditorWidget> {
  GlobalKey<FormState> _formKey;

  _RequestEditorWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    var provider = this.widget.provider;
    return WillPopScope(
        onWillPop: () {
          return showDialog(
                  context: context,
                  builder: (context) => ExitDialogWidget(
                      provider: provider,
                      requestId: this.widget.requestId,
                      onValidate: _validateUserRequest)) ??
              false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).requestEditor),
            actions: [
              IconButton(
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
                icon: Icon(Icons.save),
                tooltip: S.of(context).save,
                onPressed: () {
                  provider.onSave(this.widget.requestId, () {
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
              ),
              IconButton(
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
                icon: Icon(Icons.send),
                tooltip: S.of(context).sendTooltip,
                onPressed: () async {
                  var _isValid = _validateUserRequest(provider);
                  if (_isValid) {
                    await provider.onSelectSupportSubject(
                      this.widget.requestId, 
                      () async {
                        return await NavigationService.instance.navigateToRoute(
                          MaterialPageRoute(
                            builder: (BuildContext _context) => SelectSupportPage(provider.theme)
                          )
                        );
                      }, 
                      () {
                        NavigationService.instance
                            .goBack(result: RequestSavingResult.Published);
                      }, () {
                        NavigationService.instance
                            .goBack(result: RequestSavingResult.TimeoutExpired);
                      }, () {
                        NavigationService.instance
                            .goBack(result: RequestSavingResult.Error);
                      }
                    );
                  }
                },
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          body: ModalProgressHUD(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: _requestEditorPageUI(provider)),
              inAsyncCall: provider.isRequestLoading),
          floatingActionButton: PickUploadsWidget(provider: provider),
        ));
  }

  Widget _requestEditorPageUI(RequestEditorProvider provider) {
    return Builder(builder: (BuildContext _context) {
      SnackBarService.instance.buildContext = _context;
      var requestId = this.widget.requestId;
      if (requestId != null) {
        return FutureBuilder<UserRequest>(
            future: provider
                .getUserRequestById(requestId, S.of(_context).sdoChromatec, () {
              SnackBarService.instance.showSnackBarError(
                  S.of(context).requestLoadingTimeoutExpired);
            }, () {
              SnackBarService.instance
                  .showSnackBarError(S.of(context).requestLoadingError);
            }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _requestEditForm(provider);
              } else {
                return LoadingWidget();
              }
            });
      } else {
        return _requestEditForm(provider);
      }
    });
  }

  Widget _requestEditForm(RequestEditorProvider provider) {
    return Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              DropdownSearch(
                mode: Mode.MENU,
                showSelectedItem: true,
                label: S.of(context).selectRequestCategory,
                items: _getThemes(RequestEditorProvider.themeItems),
                onSaved: (item) {
                  provider.theme = _setTheme(item);
                },
                selectedItem: (provider.theme.isNotEmpty)
                    ? _getTheme(provider.theme)
                    : _getTheme(RequestEditorProvider.themeItems[0]),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: S.of(context).title),
                initialValue: provider.title,
                onSaved: (item) {
                  provider.title = item;
                },
                validator: (_inputText) {
                  return (_inputText.length > 0)
                      ? null
                      : S.of(context).requestTitleShouldContainAtLeast1Symbol;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: S.of(context).enterInformationAboutYourProblem),
                  initialValue: provider.description,
                  onSaved: (item) {
                    provider.description = item;
                  },
                  validator: (_inputText) {
                    return (_inputText.length > 0)
                        ? null
                        : S
                            .of(context)
                            .requestDescriptionShouldContainAtLeast1Symbol;
                  },
                  minLines: 12,
                  maxLines: 12),
              SizedBox(height: 20)
            ])),
            VerticalAttachmentsList(provider.uploads, onRemove: provider.removeUpload),
          ],
        ));
  }

  bool _validateUserRequest(RequestEditorProvider provider) => _formKey.currentState.validate();

  String _getTheme(String theme) {
    switch(theme) {
      case "Soft": return S.of(context).software;
      case "Hardware": return S.of(context).hardware;
      case "Other": return S.of(context).other;
      default: return S.of(context).other;
    }
  }

  List<String> _getThemes(List<String> themes) {
    return themes.map((theme) => _getTheme(theme)).toList();
  }

  String _setTheme(String theme) {
    if (theme == S.of(context).software) {
      return "Soft";
    } else if (theme == S.of(context).hardware) {
      return "Hardware";
    } else {
      return "Other";
    }
  }

}
