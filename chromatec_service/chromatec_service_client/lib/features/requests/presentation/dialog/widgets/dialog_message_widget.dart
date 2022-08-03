import 'package:chromatec_service/common/utils/icon_select.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DialogMessageWidget extends StatefulWidget {
  final Message message;
  final bool isOwnMessage;
  final DialogProvider provider;

  DialogMessageWidget({@required this.message, @required this.isOwnMessage, @required this.provider});

  @override
  State<DialogMessageWidget> createState() => _DialogMessageWidgetState();
}

class _DialogMessageWidgetState extends State<DialogMessageWidget> {

  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
     return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment:
              widget.isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            (!widget.isOwnMessage)
                ? _userImageWidget(widget.message.senderId, widget.provider)
                : Container(),
            SizedBox(width: _deviceWidth * 0.02),
            _messageBubble(widget.isOwnMessage, widget.message, widget.provider)
          ],
        ));
  }

   Widget _messageBubble(bool isOwnMessage, Message message, DialogProvider provider) {
    return Container(
        width: _deviceWidth * 0.75,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isOwnMessage ? Colors.blue[100] : Colors.grey[200]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (!isOwnMessage) 
              ? Align(
                  alignment: Alignment.topRight,
                  child: _getMessageSenderNameWidget(message.senderId, provider)
                )
              : Container(),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 10, left: 10),
              child: Text(message.text)
            ),
            Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                itemCount:message.uploads.length, 
                itemBuilder: (_, index) {
                  var upload = message.uploads[index];
                  return Container(
                    child: ListTile(
                      leading: Image.asset('assets/download.png', scale: 0.5),
                      title: Text(TextHelper.cutText(upload.name, 40),
                        style: TextStyle(fontSize: 13)),
                      subtitle: Text(upload.size, style: TextStyle(fontSize: 10)),
                      trailing: getUploadStatusView(upload),
                      onTap: () {
                        var uploadsForView = UploadsHelper.getUploadsListForView(message.uploads, index);
                        NavigationService.instance.navigateToRoute(MaterialPageRoute(
                          builder: (context) => UploadsGalleryPage(uploadsForView),
                        ));
                      },
                    )
                  );
                }, 
                shrinkWrap: true, 
                physics: NeverScrollableScrollPhysics()
              )
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                provider.getMessageDateTimeStringView(message.dateTime),
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w300
                )
              )
            )
          ],
        )
    );
  }

  Widget _getMessageSenderNameWidget(String senderId, DialogProvider provider) {
    return StreamBuilder<String>(
        stream: provider.getMessageSenderName(senderId),
        builder: (BuildContext _context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.brown[800]));
          } else {
            return Container();
          }
        });
  }

   Widget _userImageWidget(String senderId, DialogProvider provider) {
    double imageRadius = _deviceHeight * 0.05;
    return StreamBuilder<String>(
        stream: provider.getMessageSenderImageUrl(senderId),
        builder: (BuildContext _context, snapshot) {
          if (snapshot.hasData) {
            var url = snapshot.data;
            return Container(
              height: imageRadius,
              width: imageRadius,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(url)),
              ),
            );
          } else {
            return Container(height: imageRadius, width: imageRadius);
          }
        });
  }
}