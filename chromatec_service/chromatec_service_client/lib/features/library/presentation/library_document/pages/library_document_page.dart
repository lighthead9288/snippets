import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/presentation/library_document/state/library_document_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chromatec_service/di/di_container.dart' as di;
import 'package:webview_flutter/webview_flutter.dart';

class LibraryDocumentPage extends StatefulWidget {
  final String id;
  final String title;
  final List<String> searchResults;

  LibraryDocumentPage(
      {@required this.id, @required this.title, this.searchResults = const []});

  @override
  State<StatefulWidget> createState() => _LibraryDocumentPageState();
}

class _LibraryDocumentPageState extends State<LibraryDocumentPage> {
  WebViewController _controller;
  double _deviceWidth;
  double _deviceHeight;

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (_) => di.sl<LibraryDocumentProvider>(),
      child: Consumer<LibraryDocumentProvider>(
        builder: (_, provider, __) => _libraryDocumentPageUI(provider),
      ),
    );
  }

  Widget _libraryDocumentPageUI(LibraryDocumentProvider provider) {
    return FutureBuilder<LibraryDocument>(
        future: provider.loadLibraryDocument(widget.id),
        builder: (BuildContext _context, snapshot) {
          if (provider.isError) {
            return Scaffold(
                appBar: AppBar(title: Text(widget.title)),
                body: FailureWidget(
                    text: S.of(context).cannotLoadLibraryDocument));
          }
          if ((snapshot.connectionState == ConnectionState.active) ||
              (snapshot.connectionState == ConnectionState.done)) {
            var document = snapshot.requireData;
            return _libraryDocumentUI(document, provider);
          } else {
            return Container(
              child: LoadingWidget(),
              color: Colors.white,
            );
          }
        });
  }

  Widget _libraryDocumentUI(
      LibraryDocument document, LibraryDocumentProvider provider) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: Stack(
        children: [
          Column(
            children: [
              provider.isOffline
                  ? Container(
                      width: _deviceWidth,
                      height: _deviceHeight * 0.05,
                      decoration: BoxDecoration(color: Colors.yellow[200]),
                      child:
                          Center(child: Text(S.of(context).libraryOfflineMode)))
                  : Container(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: WebView(
                    initialUrl: "${document.url}",
                    onWebViewCreated: (_controller) {
                      this._controller = _controller;
                    },
                    onPageStarted: (_) {},
                    onPageFinished: (_) async {
                      if (widget.searchResults.isNotEmpty) {
                        var resultsString = provider
                            .getSearchResultsString(widget.searchResults);
                        if (provider.searchResultsLength == 0) {
                          await _setMarks(resultsString);
                        }
                      }
                      provider.onDocumentLoadingFinished();
                    },
                    javascriptChannels: Set.from([
                      JavascriptChannel(
                          name: 'MarksCount',
                          onMessageReceived: (msg) {
                            var length = int.parse(msg.message);
                            provider.onSearchResultsLengthInit(length);
                          })
                    ]),
                    javascriptMode: JavascriptMode.unrestricted,
                  ),
                ),
              ),
              _searchResultsNavigationUI(provider)
            ],
          ),
          _documentLoadingUI(provider)
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: _getDrawerUI(document, provider),
        ),
      ),
    );
  }

  Widget _searchResultsNavigationUI(LibraryDocumentProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<bool>(
          stream: provider.searchResultsNavigationStream,
          builder: (BuildContext _context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                        onPressed: () {
                          var position = provider.onSearchResultsDown();
                          var positionString =
                              _getScrollToPositionString(position);
                          _controller.evaluateJavascript(positionString);
                        },
                        icon: Icon(Icons.arrow_downward)),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                        onPressed: () {
                          var position = provider.onSearchResultsUp();
                          var positionString =
                              _getScrollToPositionString(position);
                          _controller.evaluateJavascript(positionString);
                        },
                        icon: Icon(Icons.arrow_upward)),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                          "${provider.curSearchResultNumber + 1}/${provider.searchResultsLength}")),
                ]);
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          }),
    );
  }

  Widget _documentLoadingUI(LibraryDocumentProvider provider) {
    return StreamBuilder<bool>(
        stream: provider.documentLoadingStream,
        builder: (BuildContext _context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  List<Widget> _getDrawerUI(
      LibraryDocument document, LibraryDocumentProvider provider) {
    var items = <Widget>[];
    items.addAll(document.menuItems
        .map((item) => ListTile(
              title: Text(item.title),
              onTap: () {
                NavigationService.instance.goBack();
                var jsString =
                    "document.querySelector('[href=\"${item.id}\"]').click();";
                _controller.evaluateJavascript(jsString);
              },
            ))
        .toList());
    items.add(Divider(thickness: 1));
    items.addAll(document.links
        .map((link) => ListTile(
              title: Text(link.title,
                  style: TextStyle(fontSize: 15, color: Colors.blueAccent)),
              onTap: () {
                provider.onLinkTap(link.id);
              },
            ))
        .toList());
    return items;
  }

  String _getScrollToPositionString(int position) {
    return "var elem = document.getElementById('result_' + $position); if (elem != null) { elem.scrollIntoView(true); } else {console.log('Cannot find element in tree')}";
  }

  void _setMarks(String resultsString) async {
    await _controller.evaluateJavascript(
        "var content = document.getElementsByClassName('content')[0].innerHTML;" +
            "var words = $resultsString" +
            "for (var j = 0; j < words.length; j++) {" +
            "content = content.replaceAll(words[j], '<mark>' + words[j] + '</mark>')" +
            "}" +
            "document.getElementsByClassName('content')[0].innerHTML = content;" +
            "var marks = document.getElementsByTagName('mark'); for (var i = 0; i < marks.length; i++) { marks[i].id = 'result_' + i; }" +
            _getScrollToPositionString(0) +
            "MarksCount.postMessage(marks.length);"
    );
  }
}
