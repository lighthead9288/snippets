import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/library/domain/entities/library_menu.dart';
import 'package:chromatec_service/features/library/presentation/library_menu/state/library_provider.dart';
import 'package:chromatec_service/features/library/presentation/library_menu/widgets/library_menu_widget.dart';
import 'package:chromatec_service/features/library/presentation/library_search/pages/library_search_page.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:chromatec_service/di/di_container.dart' as di;
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
            create: (_) => di.sl<LibraryProvider>(),
            child: Consumer<LibraryProvider>(
                builder: (_, provider, __) {
                  return FutureBuilder<LibraryMenu>(
                      future: provider.loadLibraryMenu(),
                      builder: (BuildContext _context, snapshot) {
                        if (provider.isFailure) {
                          return FailureWidget(text: S.of(context).libraryItemsError);
                        }
                        if ((snapshot.connectionState == ConnectionState.active) || (snapshot.connectionState == ConnectionState.done)) {
                          var menu = snapshot.requireData;
                          if (menu.sections.isNotEmpty) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(S.of(context).library),
                                actions: [
                                  IconButton(
                                    onPressed: () {
                                      NavigationService.instance.navigateToRoute(
                                        MaterialPageRoute(
                                          builder: (_) => LibrarySearchPage(documents: provider.documents,)
                                        )
                                      );
                                    }, 
                                    icon: Icon(Icons.search)
                                  )
                                ],
                              ),
                              body: LibraryMenuWidget(provider: provider, menu: menu,),
                            );
                          } else {
                            return Scaffold(
                              appBar: AppBar(title: Text(S.of(context).library)),
                              body: EmptyDataWidget(text: S.of(context).libraryItemsListIsEmpty)
                            );
                          }          
                        } else {
                          return Scaffold(
                            appBar: AppBar(title: Text(S.of(context).library)),
                            body: LoadingWidget()
                          );
                        }
                      },
                    );
                }
            )
      );
  }
}
