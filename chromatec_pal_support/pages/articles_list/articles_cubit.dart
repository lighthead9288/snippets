import 'dart:io';

import 'package:chromatec_pal_support/models/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final String topicId;

  ArticlesCubit(ArticlesState initialState, this.topicId) : super(initialState) {
    _fetchArticles();
  }

  void _fetchArticles() async {
    try {
      emit(ArticlesLoadingState());
      var articles = await _getArticles(topicId);
      emit(ArticlesLoadedState(articles: articles));
    } catch(e) {
      emit(ArticlesErrorState());
    }
  }

  Future<List<Article>> _getArticles(String topicId) async {
    if (Platform.isWindows) {
      var docs = await Firestore.instance.collection("Articles").where('topicsIds', arrayContains: topicId).orderBy('number', descending: false).get();
      return docs.map((doc) => _fromFirebaseSnapshotToArticle(doc.map, doc.id)).toList();
    } else {
      var data = await FirebaseFirestore.instance.collection("Articles").where('topicsIds', arrayContains: topicId).orderBy('number', descending: false).get();
      return data.docs.map((doc) => _fromFirebaseSnapshotToArticle(doc.data(), doc.id)).toList();
    }    
  }

  Article _fromFirebaseSnapshotToArticle(Map<String, dynamic> data, String id) {
    var mainImageUrl = data["mainImageUrl"];
    var topicsIds = data["topicsIds"];
    List<LocaleItem> localeNameItems = [];
    var localeNameItemsData = data["localeNameItems"];
    if (localeNameItemsData is List) {
      _fromDynamicDataToLocaleItems(localeNameItemsData, (item) { 
        localeNameItems.add(item);
      });
    }
    List<LocaleItem> localeDescriptionItems = [];
    var localeDescriptionItemsData = data["localeDescriptionItems"];
    if (localeDescriptionItemsData is List) {
      _fromDynamicDataToLocaleItems(localeDescriptionItemsData, (item) { 
        localeDescriptionItems.add(item);
      });
    }

    List<ArticleVersion> articleVersions = [];
    var articleVersionsData = data["versions"];
    if (articleVersionsData is List) {
      print(articleVersionsData.length);
      articleVersionsData.map((version) {
        var id = version["id"];
        var name = version["name"];
        var url = version["url"];
        print(name);
        print(url);
        if (url is String) {
          articleVersions.add(ArticleVersion(id: id, name: name, url: url));
        }
      }).toList();
    }    

    return Article(
      id: id, 
      localeNameItems: localeNameItems,
      localeDescriptionItems: localeDescriptionItems, 
      versions: articleVersions, 
      topicIds: (topicsIds is List<String>) ? topicsIds : [],       
      mainImageUrl: (mainImageUrl is String) ? mainImageUrl : ""
    );
  }

  void _fromDynamicDataToLocaleItems(List data, void Function(LocaleItem item) onAdd) {
    data.map((item) {
        var id = item["id"];
        var value = item["value"];
        if ((id is String) && (value is String)) {
          onAdd(LocaleItem(id: id, value: value));
        }
      }).toList();
  }  
}

abstract class ArticlesState extends Equatable {}

class ArticlesLoadingState extends ArticlesState {
  @override
  List<Object?> get props => [];
}

class ArticlesErrorState extends ArticlesState {
  @override
  List<Object?> get props => [];
}

class ArticlesLoadedState extends ArticlesState {
  final List<Article> articles;

  ArticlesLoadedState({required this.articles});

  @override
  List<Object?> get props => [ articles ];
}