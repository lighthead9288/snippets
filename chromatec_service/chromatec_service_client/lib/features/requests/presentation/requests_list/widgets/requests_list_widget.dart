import 'package:chromatec_service/common/models/failure.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/widgets/request_card_widget.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/pages/request_editor_page.dart';
import 'package:core/core.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

class RequestsListWidget extends StatefulWidget {
  RequestsListProvider provider;

  RequestsListWidget({@required this.provider});

  @override
  State<StatefulWidget> createState() => RequestsListWidgetState();
}

class RequestsListWidgetState extends State<RequestsListWidget> {

  double _deviceHeight;
  double _deviceWidth;
  ScrollController _requestsScrollController;

  RequestsListWidgetState() {
    _requestsScrollController = ScrollController();
  }

  @override
  void initState() {
    super.initState();

    _requestsScrollController.addListener(() {
      double maxScroll = _requestsScrollController.position.maxScrollExtent;
      double currentScroll = _requestsScrollController.position.pixels;
      if (maxScroll == currentScroll) {
        print("Fetch more data");
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = this.widget.provider;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        appBar: _requestsAppBar(provider),
        body: Column(
          children: [
            Expanded(
              child: _requestsBody(provider)
            ),                    
            (provider.loadingMode == LoadingMode.Online) 
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  height: _deviceHeight * 0.05,
                  width: _deviceWidth,
                  color: Colors.grey[700],
                  child: Center(
                    child: Text(S.of(context).requestsLoadedFromCache, style: TextStyle(color: Colors.white),)
                  )
                )            
          ]
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(vertical: 27),
          child: FloatingActionButton(
            onPressed: () async {
              await provider.onAddRequest(_goToNewRequest, _showRequestSavingResult);
            },
            child: Icon(Icons.add)
          )
        )
      ), 
      onWillPop: () async {
        provider.onExit();
        return true;
      }
    );
  }

   Widget _requestsAppBar(RequestsListProvider provider) {
    return AppBar(
      title: DropdownButton(
        isExpanded: true,
        items: [
          DropdownMenuItem(
            value: EnumToString.convertToString(RequestsFilter.All),
            child: Row(
              children: [
                Icon(Icons.all_inbox),
                SizedBox(width: 10),
                Text(
                  S.of(context).all,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
              ],
            ),
          ),
          DropdownMenuItem(
            value: EnumToString.convertToString(RequestsFilter.Published),
            child: Row(
              children: [
                Icon(Icons.send),
                SizedBox(width: 10),
                Text(S.of(context).published,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
              ]
            )
          ),
          DropdownMenuItem(
            value: EnumToString.convertToString(RequestsFilter.Saved),
            child: Row(
              children: [
                Icon(Icons.save),
                SizedBox(width: 10),
                Text(S.of(context).saved,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
              ]
            )
          )
        ],
        value: EnumToString.convertToString(provider.requestsFilter),
        onChanged: (item) {
          provider.onUpdateRequestFilter(EnumToString.fromString(RequestsFilter.values, item));
        }
      )
    );
    
  }

  Widget _requestsBody(RequestsListProvider provider) {
    List<UserRequest> loadedRequests = provider.requests;
    return StreamBuilder<UserRequestsResponse>(
        stream: provider.getRequests(),
        initialData: UserRequestsResponse(DataFromServerSuccess(), requests: loadedRequests),
        builder: (BuildContext _context, _snapshot) {
          if (_snapshot.data.status is Failure) {
            return FailureWidget(text: S.of(context).requestsListLoadingError);
          }
          if ((_snapshot.connectionState == ConnectionState.active) || (_snapshot.connectionState == ConnectionState.done)) {
            return (_snapshot.data.requests.length != 0)
              ? _requestsList(_snapshot.data.requests, provider)
              : EmptyDataWidget(text: S.of(context).requestsListIsEmpty);
          } else if (loadedRequests.length != 0) {
            return _requestsListWithBottomLoading(loadedRequests, provider);
          } else {
            return LoadingWidget();
          }
        });
  }

  Widget _requestsListWithBottomLoading(List<UserRequest> requests, RequestsListProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.all(5),
      controller: _requestsScrollController,
      itemCount: requests.length + 1,
      itemBuilder: (BuildContext _context, index) {
        return (index < requests.length)
            ? RequestCard(
                request: requests[index], 
                provider: provider, 
                goToRequestEditor: _goToRequestEditor, 
                showRequestSavingResult: _showRequestSavingResult,
                onDelete: provider.onDeleteRequest,
            )
            : LoadingWidget();
      },
    );
  }

  Widget _requestsList(List<UserRequest> requests, RequestsListProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.all(5),
      controller: _requestsScrollController,
      itemCount: requests.length,
      itemBuilder: (BuildContext _context, index) =>
        RequestCard(
          request: requests[index], 
          provider: provider, 
          goToRequestEditor: _goToRequestEditor, 
          showRequestSavingResult: _showRequestSavingResult,
          onDelete: provider.onDeleteRequest,
        )
    );
  }
  
  Future<RequestSavingResult> _goToNewRequest() async {
    return await NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) =>
          RequestEditorPage()
      )
    );
  }

  Future<RequestSavingResult> _goToRequestEditor(UserRequest request) async {
    return await NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) =>
          RequestEditorPage.setRequestId(request.id)
      )
    );
  }  

  void _showRequestSavingResult(RequestSavingResult _result) {
    switch (_result) {
      case RequestSavingResult.Published:
        SnackBarService.instance
            .showSnackBarSuccess(S.of(context).requestWasSuccessfullyPublished);
        break;
      case RequestSavingResult.Saved:
        SnackBarService.instance
            .showSnackBarInfo(S.of(context).requestWasSavedToRough);
        break;
      case RequestSavingResult.Error:
        SnackBarService.instance
            .showSnackBarError(S.of(context).requestSavingError);
        break;
      case RequestSavingResult.TimeoutExpired:
        SnackBarService.instance
            .showSnackBarError(S.of(context).requestSavingTimeoutExpired);
        break;
    }
  }

}