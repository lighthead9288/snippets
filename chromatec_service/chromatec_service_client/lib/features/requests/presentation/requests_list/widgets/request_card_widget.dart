import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/pages/dialog_page.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatefulWidget {
  final UserRequest request;
  final RequestsListProvider provider;
  final Future<void> Function(UserRequest userRequest) goToRequestEditor;
  final void Function(RequestSavingResult result) showRequestSavingResult;
  final Future<void> Function(UserRequest userRequest) onDelete;

  RequestCard({
    @required this.request, 
    @required this.provider, 
    @required this.goToRequestEditor, 
    @required this.showRequestSavingResult,
    @required this.onDelete
  });

  @override
  State<StatefulWidget> createState() => RequestCardState();
}

class RequestCardState extends State<RequestCard> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var request = this.widget.request;
    var provider = this.widget.provider;
    var isMe = provider.isMe(request, request.ownerId);
    return (isMe) 
      ? Dismissible(
          key: UniqueKey(),
          onDismissed: (_) async {
            await widget.onDelete(request);
          },
          child: _requestCard(request, provider, isMe) 
        )
      : _requestCard(request, provider, isMe);
  }

  Widget _requestCard(UserRequest request, RequestsListProvider provider, bool isMe) {
    return Card(
        child: ListTile(
          onTap: () async {
            await provider.onRequestSelect(request, _goToDialog, this.widget.goToRequestEditor, this.widget.showRequestSavingResult);
          },
          leading: request.isPublished
            ? Stack(
                children: [
                  Image.asset('assets/published_request.png'),
                  Positioned(
                    bottom: 11,
                    right: 0,
                    child: _getRequestOwnerPhoto(request, provider, isMe)
                  )
                ]
              )
            : Image.asset('assets/rough_request.png'),
          title: Text(request.title),
          subtitle: StreamBuilder<String>(
            stream: provider.getLastMessage(request),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.requireData);
              } else {
                return Container();
              }
            },
          ),
          trailing: isMe 
            ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await widget.onDelete(request);
                }
              )
            : SizedBox()
        )
      );
  }

  Widget _getRequestOwnerPhoto(UserRequest request, RequestsListProvider provider, bool isMe) {
    double imageRadius = _deviceHeight * 0.03;
    if (!isMe) {
      print(request.ownerId);
      return StreamBuilder<String>(
        stream: provider.getRequestOwnerPhoto(request),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            var url = snapshot.requireData;
            return Container(
              height: imageRadius,
              width: imageRadius,              
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow[900], width: 2),                
                borderRadius: BorderRadius.circular(500),
                image: DecorationImage(
                  fit: BoxFit.cover, 
                  image: (url != "")
                    ? NetworkImage(url)
                    : AssetImage("assets/unknown_user.png")
                )
              ),
            );
          } else {
            return Container();
          }
        }
      );
    } else {
      return Container();
    }
  }

  Future<void> _goToDialog(UserRequest request) async {
    await NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) =>
          DialogPage(requestId: request.id, requestTitle: request.title)
    )
    );
  }
}