import 'package:chromatec_service/features/account/presentation/login/pages/login_page.dart';
import 'package:chromatec_service/features/catalog/presentation/pages/catalog_page.dart';
import 'package:chromatec_service/features/dealer_reports/presentation/dealer_reports_list/pages/dealer_reports_page.dart';
import 'package:chromatec_service/features/home/presentation/pages/home_page.dart';
import 'package:chromatec_service/features/home/presentation/state/home_page_provider.dart';
import 'package:chromatec_service/features/language/presentation/pages/language_settings_page.dart';
import 'package:chromatec_service/features/lessons/presentation/pages/lessons_page.dart';
import 'package:chromatec_service/features/library/presentation/library_menu/pages/library_page.dart';
import 'package:chromatec_service/features/profile/presentation/profile_editor/pages/profile_page.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/pages/requests_page.dart';
import 'package:chromatec_service/features/software_activation/presentation/pages/software_activation_page.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MenuRenderStrategy {
  final double deviceHeight;
  final double deviceWidth;

  MenuRenderStrategy({@required this.deviceHeight, @required this.deviceWidth});

  List<Widget> render(HomePageProvider provider, {User user});

  Widget getLoggedDrawerItem(User user) {
    double imageRadius = deviceHeight * 0.09;
    return DrawerHeader(
        child: GestureDetector(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: imageRadius,
                  width: imageRadius,
                  decoration: BoxDecoration(        
                    borderRadius: BorderRadius.circular(imageRadius),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (user.imageUrl.isEmpty) ? AssetImage('assets/unknown_user.png') : NetworkImage(user.imageUrl)
                    )
                  )
                ),
                SizedBox(height: 3,),
                Text(
                  "${user.name} ${user.surname}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
                ),
                Text(
                  user.email, 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)
                ),
              ],
            ),
          ),
          onTap: () {
            NavigationService.instance.navigateToRoute(
              MaterialPageRoute(
                builder: (BuildContext _context) => ProfilePage()
              )
            );
          },
        ),
        decoration: BoxDecoration(color: Colors.blue[200])
      );
  }

  List<Widget> getCommonItems() {
    return [
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).catalog),
            leading: Icon(Icons.library_books),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(builder: (_context) => CatalogPage()),
                  popBackStack: true);
            },
          );
        }
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).lessons),
            leading: Icon(Icons.science),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(builder: (_context) => LessonsPage()),
                  popBackStack: true);
            },
          );
        }
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).library),
            leading: Icon(Icons.book),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                MaterialPageRoute(
                  builder: ((context) => LibraryPage()),
                ), popBackStack: true
              );
            },
          );
        }
      )
    ];
  }

  List<Widget> getUserItems() {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).requests),
            leading: Icon(Icons.request_page),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(builder: (_context) => RequestsPage()),
                  popBackStack: true);
            },
          );
        }
      ),
    ];
  }

  List<Widget> getSoftwareActivationItems() {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).softwareActivation),
            leading: Icon(Icons.qr_code),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(
                      builder: (_context) => SoftwareActivationPage()),
                  popBackStack: true);
            },
          );
        }
      )
    ];
  }

  List<Widget> getLogoutItems(HomePageProvider provider) {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).logout),
            leading: Icon(Icons.logout),
            onTap: () {
              provider.onLogout(() async {
                await NavigationService.instance.navigateToRouteWithReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomePage()
                  )
                );
              });
            },
          );
        }
      )
    ];
  }

  List<Widget> getLanguageItems() {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).languageSettings),
            leading: Icon(Icons.language),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                MaterialPageRoute(builder: (_context) => LanguageSettingsPage()),
                popBackStack: true);
            },
          );
        }
      )
    ];
  }

  List<Widget> getDealerItems({bool isEmployee = false}) {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).dealerReports),
            leading: Icon(Icons.report_problem),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(builder: (_context) => DealerReportsPage(isEmployee: isEmployee)),
                  popBackStack: true);
            },
          );
        }
      )
    ];
  }

  Widget getDefaultDrawerItem() {
    return DrawerHeader(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: deviceHeight * 0.005, bottom: deviceHeight * 0.005),
          height: deviceHeight * 0.05,
          width: deviceWidth * 0.05,
          child: Image.asset('assets/unknown_user.png')
        ),
        decoration: BoxDecoration(color: Colors.blue[200])
    );
  }

  List<Widget> getLoginItems() {
    return [
      Divider(
        thickness: 1,
      ),
      Builder(
        builder: (context) {
          return ListTile(
            title: Text(S.of(context).login),
            leading: Icon(Icons.login),
            onTap: () {
              NavigationService.instance.navigateToRoute(
                  MaterialPageRoute(builder: (_context) => LoginPage()),
                  popBackStack: true);
            },
          );
        }
      )
    ];
  }

  

}