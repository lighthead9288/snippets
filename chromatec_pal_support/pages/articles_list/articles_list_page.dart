import 'dart:io';

import 'package:chromatec_pal_support/models/article.dart';
import 'package:chromatec_pal_support/models/topic.dart';
import 'package:chromatec_pal_support/pages/articles_list/articles_cubit.dart';
import 'package:chromatec_pal_support/services/navigation_service.dart';
import 'package:chromatec_pal_support/pages/article/article_page.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ArticlesListPage extends StatefulWidget {
  final Topic topic;

  const ArticlesListPage({Key? key, required this.topic}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArticlesListPageState();
}

class _ArticlesListPageState extends State<ArticlesListPage> {
  late double _deviceHeight;
  late double _deviceWidth;
 
  @override
  Widget build(BuildContext context) {
    var topic = widget.topic;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
    return Scaffold(
      appBar: widgetsFactory.createAppBar().render(topic.name),
      body: Center(child: _articlesList(topic))
    );
  }

  Widget _articlesList(Topic topic) {
    return BlocProvider(
      create: (_) => ArticlesCubit(ArticlesLoadingState(), topic.id),
      child: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder: (_, state) {
          if (state is ArticlesLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ArticlesErrorState) {
            return Center(child: Text('Articles list loading error :('));
          } else if (state is ArticlesLoadedState) {
            var articles = state.articles;
            return (articles.isNotEmpty) ? _articlesListUI(articles): Center(child: Text('No articles yet'));
          } else {
            return Container();
          }
        }
      ),
    );
  }

  Widget _articlesListUI (List<Article> articles) {
    return ListView.builder(
        itemCount: articles.length,
        itemBuilder: (_context, index) {
          var article = articles[index];
          return GestureDetector(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      child: Text(article.localeDescriptionItems.first.value, style: TextStyle(fontFamily: "EBGaramond", fontSize: 15)), 
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    Container(
                      height: _deviceHeight * 0.25,
                      width: (_deviceWidth > 500) ? 500 : _deviceWidth,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: article.mainImageUrl.isNotEmpty 
                        ? FadeInImage.assetNetwork(
                            placeholder: "assets/image_placeholder.png", 
                            image: article.mainImageUrl,
                            fit: BoxFit.fill
                          )
                        : Image.asset("assets/image_placeholder.png", fit: BoxFit.fill)
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        article.localeNameItems.first.value, 
                        style: TextStyle(fontFamily: "PTSansNarrow", fontSize: 30, fontWeight: FontWeight.bold)
                      ),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article)
                )
              );
            },
          );
        }
      );
  }
}