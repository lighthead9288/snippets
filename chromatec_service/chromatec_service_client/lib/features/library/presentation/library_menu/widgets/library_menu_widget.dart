import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/presentation/library_document/pages/library_document_page.dart';
import 'package:chromatec_service/features/library/presentation/library_menu/state/library_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LibraryMenuWidget extends StatefulWidget {
  final LibraryProvider provider;
  final LibraryMenu menu;

  LibraryMenuWidget({@required this.provider, @required this.menu});

  @override
  State<StatefulWidget> createState() => _LibraryMenuWidgetState();

}

class _LibraryMenuWidgetState extends State<LibraryMenuWidget> {
  double _deviceWidth;
  double _deviceHeight;

  @override
  Widget build(BuildContext context) { 
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return _libraryMenuUI(widget.menu);
  } 

  Widget _libraryMenuUI(LibraryMenu menu) {
    return Column(
      children: [
        (widget.provider.isOffline) 
          ? Container(
              width: _deviceWidth,
              height: _deviceHeight * 0.05,
              decoration: BoxDecoration(color: Colors.yellow[200]),
              child: Center(child: Text(S.of(context).libraryOfflineMode))
            )
          : Container(),
        Expanded(
          child: ListView.builder(
            itemCount: menu.sections.length,
            itemBuilder: (BuildContext _context, int index) => ListTile(
              title: ExpansionTile(
                initiallyExpanded: true,
                title: Text(menu.sections[index].name, style: TextStyle(fontSize: 30)),
                children: _chaptersUI(menu.sections[index].chapters),
              )
            )
          )
        )
      ],
    );
  }

  List<Widget> _chaptersUI(List<LibraryMenuChapter> chapters) {
    return chapters.map((chapter) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(chapter.name, style: TextStyle(fontSize: 20)),
            Flexible(
              child: _linksUI(chapter.links), 
              fit: FlexFit.loose
            )
          ],
        ),
      );
    }).toList();
  }

  Widget _linksUI(List<LibraryMenuLink> links) {
    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (BuildContext _context, int index) {
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(links[index].title, style: TextStyle(fontSize: 15, color: Colors.blueAccent))
          ),
          onTap: () {
            NavigationService.instance.navigateToRoute(
              MaterialPageRoute(builder: (context) => LibraryDocumentPage(id: links[index].id, title: links[index].title))
            );
          },
        );
      },
      shrinkWrap: true, 
      physics: NeverScrollableScrollPhysics()
    );
  }
}