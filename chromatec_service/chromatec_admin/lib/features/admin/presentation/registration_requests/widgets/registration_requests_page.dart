import 'package:chromatec_admin/features/admin/presentation/registration_requests/state/registration_requests_provider.dart';
import 'package:chromatec_admin/widgets/select_user_role_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_admin/di/di_container.dart' as di;

class RegistrationRequestsPage extends StatefulWidget {
  const RegistrationRequestsPage({ Key key }) : super(key: key);

  @override
  State<RegistrationRequestsPage> createState() => _RegistrationRequestsPageState();
}

class _RegistrationRequestsPageState extends State<RegistrationRequestsPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => di.sl<RegistrationRequestsProvider>(),
        child: Consumer<RegistrationRequestsProvider>(
          builder: (_, provider, __) => _ui(provider),
        ),
      )
    );
  }

  Widget _ui(RegistrationRequestsProvider provider) {
    return (!provider.isLoading) 
      ? FutureBuilder<List<RegistrationRequest>>(
          initialData: const [],
          future: provider.getRequests(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var requests = snapshot.data;
              if (requests.isEmpty) {
                return EmptyDataWidget(text: S.of(context).requestsListIsEmpty);
              }
              return _requestsList(requests, provider);
            } else {
              return LoadingWidget();
            }
          }
        ) 
      : LoadingWidget();
  }

  Widget _requestsList(List<RegistrationRequest> requests, RegistrationRequestsProvider provider) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_ ,index) {
        var request = requests[index];
        var cardHeight = (request.uploads.isNotEmpty) ? _deviceHeight * 0.3 : _deviceHeight * 0.15; 
        return Card(          
            child: SizedBox(
              height: cardHeight,
              child: Column(
                children: [
                  ListTile(  
                    enabled: request.status != RegistrationRequestStatus.Rejected,                  
                    leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/unknown_user.png")
                          )                          
                        ),
                      ),
                    title: Text("${request.name} ${request.surname}"),
                    subtitle: Text(request.email),
                    trailing: (request.status == RegistrationRequestStatus.Rejected) 
                      ? Padding(child: Text(S.of(context).rejected, style: TextStyle(color: Colors.grey)), padding: EdgeInsets.only(bottom: 20))
                      : const Text(''),
                  ),
                  request.uploads.isNotEmpty 
                    ? SizedBox(
                        height: cardHeight * 0.5,
                        width: _deviceWidth * 0.9,
                        child: HorizontalAttachmentsListWidget(uploads: request.uploads),
                      )
                    : Container(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context, 
                                builder: (_) => ConfirmRegistrationRequestDialogWidget(
                                  request: request, 
                                  provider: provider,
                                  onSuccess: () async {},
                                  onError: () async => SnackBarService.instance.showSnackBarError(S.of(context).registeringError),
                                )
                              );
                            }, 
                            child: Text(S.of(context).confirm, style: TextStyle(fontSize: 10))
                          ),
                          
                        ),
                        (request.status != RegistrationRequestStatus.Rejected) 
                          ? Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: OutlinedButton(
                                onPressed: () {
                                  provider.onRejectRequest(request.id);
                                }, 
                                child: Text(S.of(context).reject, style: TextStyle(fontSize: 10, color: Colors.red))
                              ),
                            )
                          : Container()
                      ],
                  )
                ],
              ),
            )          
        );
      }
    );
  }
  
}

class ConfirmRegistrationRequestDialogWidget extends StatefulWidget {
  final RegistrationRequest request; 
  final RegistrationRequestsProvider provider;
  final Future<void> Function() onSuccess;
  final Future<void> Function() onError;

  const ConfirmRegistrationRequestDialogWidget({ 
    Key key, 
    @required this.provider, 
    @required this.request,
    @required this.onSuccess,
    @required this.onError
  }) : super(key: key);

  @override
  State<ConfirmRegistrationRequestDialogWidget> createState() => _ConfirmRegistrationRequestDialogWidgetState();
}

class _ConfirmRegistrationRequestDialogWidgetState extends State<ConfirmRegistrationRequestDialogWidget> {
  double _deviceHeight;
  GlobalKey<FormState> _formKey;

  _ConfirmRegistrationRequestDialogWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    return AlertDialog(      
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            child: Text(S.of(context).confirm, style: TextStyle(color: Colors.blue[200])),
            onTap: () {
              if (_formKey.currentState.validate()) {
                NavigationService.instance.goBack();
                widget.provider.onConfirmRequest(widget.request, widget.onSuccess, widget.onError);
              }              
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: GestureDetector(
            child: Text(S.of(context).cancel, style: TextStyle(color: Colors.red)),
            onTap: () {
              NavigationService.instance.goBack();
            },
          ),
        )        
      ],
      content: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          height: _deviceHeight * 0.2,
          child: Column(
            children: [
              SelectUserRoleWidget(
                role: widget.provider.role, 
                onChanged: (value) {  
                  setState(() {
                    widget.provider.role = value;
                  });
                }, 
                isExpanded: true
              ),
              TextFormField(
                initialValue: widget.provider.password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: S.of(context).enterYourPassword,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[200])
                  )
                ),
                validator: (inputString) {
                  return (inputString.isNotEmpty) ? null : S.of(context).enterValidPassword;
                },
                onChanged: (inputString) {
                  widget.provider.password = inputString;
                },
              ),              
            ],
          ) ,
        ),
      ),
    );
  }
}