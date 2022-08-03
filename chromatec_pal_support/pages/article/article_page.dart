import 'dart:io';

import 'package:chromatec_pal_support/models/article.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ArticlePage extends StatefulWidget {
  final Article article;

  ArticlePage({required this.article});

  @override
  State<StatefulWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String _curArticleVersionId = "";
  late ArticleVersion _curArticleVersion;
  late double _deviceHeight;
  late double _deviceWidth;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var article = widget.article;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var name = article.localeNameItems.first.value;
    var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
    return Scaffold(
      appBar: widgetsFactory.createAppBar().render(name),
      body: _articleUI(article)
    );
  }

  Widget _articleUI(Article article) {
    if (article.versions.isEmpty) {
      return Container();
    } else {
      _curArticleVersionId = (_curArticleVersionId.isEmpty) ? article.versions.first.id: _curArticleVersionId;
      _curArticleVersion = article.versions.where((version) => version.id == _curArticleVersionId).first;
      return Column(
        children: [
          Container(
            child: _versionsSelectWidget(article.versions), 
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(right: 10)
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SfPdfViewer.network(
              _curArticleVersion.url,
              key: _pdfViewerKey,
            ),
          )
        ],
      );
    }    
  }  

  Widget _versionsSelectWidget(List<ArticleVersion> versions) {
    return (versions.length > 1) 
            ? DropdownButton(
                items: _getVersionsList(versions),
                value: _curArticleVersionId,
                onChanged: (value) {
                  setState(() {
                    _curArticleVersionId = value.toString();                    
                  });
                },
              )
            : Container();
  }

  List<DropdownMenuItem<String>> _getVersionsList(List<ArticleVersion> versions) {
    return versions.map((version) => DropdownMenuItem(
      child: Text(version.name),
      value: version.id,
    )).toList();
  }
}