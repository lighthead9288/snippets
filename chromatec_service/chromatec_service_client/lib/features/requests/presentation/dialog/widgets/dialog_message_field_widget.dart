import 'package:chromatec_service/common/widgets/attachments_dialog.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DialogMessageFieldWidget extends StatefulWidget {

  final DialogProvider provider;
  final String requestId;

  DialogMessageFieldWidget({@required this.provider, @required this.requestId});

  @override
  State<StatefulWidget> createState() => _DialogMessageFieldWidgetState();

}

class _DialogMessageFieldWidgetState extends State<DialogMessageFieldWidget> {

  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;

  _DialogMessageFieldWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var provider = this.widget.provider;
    return Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(15),
            border: Border(
                top: BorderSide(color: Colors.blue[200]),
                bottom: BorderSide(color: Colors.blue[200]),
                left: BorderSide(color: Colors.blue[200]),
                right: BorderSide(color: Colors.blue[200]))),
        child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _deviceHeight * 0.3),
            child: Form(
                key: _formKey,
                onChanged: () {
                  _formKey.currentState.save();
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: _deviceWidth * 0.03),
                      _messageTextField(provider),
                      SizedBox(width: _deviceWidth * 0.07),
                      _attachmentsButton(context, provider),
                      SizedBox(width: _deviceWidth * 0.03),
                      _sendMessageButton(context, provider)
                    ]))));
  }

  Widget _messageTextField(DialogProvider provider) {
    return SizedBox(
        width: _deviceWidth * 0.71,
        child: TextFormField(
          validator: (input) {
            if ((input.length == 0) && (provider.uploads.length == 0)) {
              return S
                  .of(context)
                  .messageShouldContainAtLeast1SymbolOrAtLeast1Attachment;
            }
            return null;
          },
          onSaved: (input) {
            provider.messageText = input;
          },
          cursorColor: Colors.blue[200],
          decoration: InputDecoration(
              border: InputBorder.none, hintText: S.of(context).typeMessage),
          autocorrect: false,
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ));
  }

  Widget _sendMessageButton(BuildContext _context, DialogProvider provider) {
    return Container(
        height: _deviceHeight * 0.05,
        width: _deviceWidth * 0.05,
        child: GestureDetector(
            child: Icon(Icons.send, color: Colors.blue[200]),
            onTap: () {
              if (_formKey.currentState.validate()) {
                FocusScope.of(_context).unfocus();
                provider.onAddMessage(this.widget.requestId, () {
                  SnackBarService.instance.showSnackBarError(S.of(context).messageSendingError);
                }, () {
                  SnackBarService.instance.showSnackBarError(S.of(context).messageSendingTimeout);
                });
                _formKey.currentState.reset();
              }
            }));
  }

  Widget _attachmentsButton(BuildContext _context, DialogProvider provider) {
    return Container(
        height: _deviceHeight * 0.05,
        width: _deviceWidth * 0.05,
        child: GestureDetector(
          child: Icon(Icons.file_present, color: Colors.blue[200]),
          onTap: () {
            showDialog(
              context: _context,
              builder: (context) {
                return AttachmentsDialog(provider: provider);
              },
            );
          },
        ));
  }


}