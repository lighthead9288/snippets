import 'package:chromatec_service/features/library/domain/entities/library_document.dart';
import 'package:chromatec_service/features/library/domain/entities/library_search_result.dart';
import 'package:chromatec_service/features/library/presentation/library_document/pages/library_document_page.dart';
import 'package:chromatec_service/features/library/presentation/library_search/state/library_search_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_service/di/di_container.dart' as di;
import 'package:provider/provider.dart';

class LibrarySearchPage extends StatefulWidget {
  final List<LibraryDocument> documents;

  LibrarySearchPage({@required this.documents});

  @override
  State<StatefulWidget> createState() => _LibrarySearchPageState();  
}

class _LibrarySearchPageState extends State<LibrarySearchPage> {

  LibrarySearchProvider librarySearchProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          onChanged: (value) {
            librarySearchProvider.searchString = value;
          },
          onEditingComplete: () {
            librarySearchProvider.getFilteredList();
          },        
        ), 
      ),
      body: ChangeNotifierProvider(
        create: (_) => di.sl<LibrarySearchProvider>(),
        child: Consumer<LibrarySearchProvider>(
          builder: (_, provider, __) {
            librarySearchProvider = provider;
            return _libraryDocsListUI(provider);
          },
        ),
      )
    );
  }

  Widget _libraryDocsListUI(LibrarySearchProvider provider) {
    provider.setDocumentsList(widget.documents);
    return ListView.builder(
      itemCount: provider.filteredDocuments.length,
      itemBuilder: (BuildContext _context, int index) {
        return _libraryDocumentCard(provider.filteredDocuments[index]);
      }
    );
  }

  Widget _libraryDocumentCard(LibrarySearchResult document) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Image.asset('assets/logo_2.jpg'),
        title: Text(document.document.title),
        onTap: () {
          NavigationService.instance.navigateToRoute(
            MaterialPageRoute(
              builder: (_) => LibraryDocumentPage(
                id: document.document.id, 
                title: document.document.title,
                searchResults: document.results,
              )
            )
          );
        },
      ),
    );
  }

}