import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_search_result.dart';
import 'package:flutter/foundation.dart';

class LibrarySearchProvider extends ChangeNotifier {
  List<LibraryDocument> documents = [];
  List<LibrarySearchResult> filteredDocuments = [];
  
  String _searchString = "";
  String get searchString => _searchString;
  set searchString(String value) {
    _searchString = value;
    notifyListeners();
  }

  LibrarySearchProvider();

  void setDocumentsList(List<LibraryDocument> docs) {
    if (documents.isNotEmpty) {
      return;
    }
    documents = docs;
    filteredDocuments = documents.map((doc) => LibrarySearchResult(document: doc, results: [])).toList();
  }

  void getFilteredList() async {
    filteredDocuments = await compute(_computeResults, FilterLibraryRequest(documents: documents, searchString: searchString));
    notifyListeners();
  }

  static List<LibrarySearchResult> _computeResults(FilterLibraryRequest request) {
    return FilterLibraryDocs().filter(request);
  }

}

class FilterLibraryRequest {
  final String searchString;
  final List<LibraryDocument> documents;

  FilterLibraryRequest({@required this.documents, @required this.searchString});
}

class FilterLibraryDocs {
  List<LibrarySearchResult> filter(FilterLibraryRequest request) {  
    var results = request.documents.map((document) => _getSearchResult(document, request.searchString.toLowerCase()))
      .where((element) => element.titleContains || element.results.isNotEmpty)
      .toList();
    results.sort((a, b) => b.results.length.compareTo(a.results.length));
    return results;
  }

  LibrarySearchResult _getSearchResult(LibraryDocument document, String searchString) {
    List<String> foundedMatches = [];

    // Direct order
    var words = _splitSearchStringToWords(searchString);  
    foundedMatches.addAll(_getMatchesInDocument(words, searchString, document.keywords));

    // Reversed order
    var reversedWords = words.reversed.toList();
    foundedMatches.addAll(_getMatchesInDocument(reversedWords, searchString, document.keywords));

    // Is search string exists in title
    bool titleContains = _getMatchesInDocument(words, searchString, document.title.toLowerCase()).isNotEmpty;
    titleContains &= _getMatchesInDocument(reversedWords, searchString, document.title.toLowerCase()).isNotEmpty;
    
    return LibrarySearchResult(document: document, results: foundedMatches, titleContains: titleContains);
  }

  List<String> _getMatchesInDocument(List<String> words, String searchString, String stringSearchedIn) {
    var pattern = _makeRegexPattern(words, searchString);
    var regExp = RegExp(pattern, caseSensitive: false);
    var matches = regExp.allMatches(stringSearchedIn);
    var foundedItems = matches.map((element) => stringSearchedIn.substring(element.start, element.end).trim()).toList();
    return foundedItems;
  }

  String _makeRegexPattern(List<String> words, String searchString) {
    String result = "";
    for(int i = 0; i < words.length; i++) {
      bool isLast = i == words.length - 1;
      var word = words[i];
      String wordEndPattern = "[^?]{1,3}[.,; \n]";
      result += (word.length > 3) 
          ? word.substring(0, word.length - 2) + ((!isLast) ? wordEndPattern : "[^?]{1,3}") 
          : word + ("[^?]{1,3}");      
    }
    return result;
  }

  List<String> _splitSearchStringToWords(String searchString) => searchString.split(" ");
}