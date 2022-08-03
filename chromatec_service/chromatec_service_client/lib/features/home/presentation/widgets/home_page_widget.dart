import 'package:chromatec_service/features/home/presentation/state/home_page_provider.dart';
import 'package:chromatec_service/features/home/presentation/widgets/menu_render_strategy.dart';
import 'package:chromatec_service/features/news/presentation/pages/news_page.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class HomePageWidget extends StatefulWidget {
  final HomePageProvider provider;
  final AuthProvider auth;

  HomePageWidget({@required this.provider, @required this.auth});

  @override
  State<StatefulWidget> createState() => _HomePageWidgetState();

}

class _HomePageWidgetState extends State<HomePageWidget> {
  double _deviceHeight;
  double _deviceWidth; 

  List<Widget> _menuItems;

  @override
  void initState() {
    super.initState();
    var provider = this.widget.provider;
    if (provider != null) {
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       provider.onInit();
     });
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var provider = this.widget.provider;
    var auth = this.widget.auth;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).chromatecService),
      ),
      drawer: _menuUI(provider, auth),
      body: NewsPage()
    );
  }

  Widget _menuUI(HomePageProvider provider, AuthProvider auth) {
    _menuItems = DefaultMenuRenderStrategy(_deviceHeight, _deviceWidth).render(provider);
    return Drawer(
      child: Builder(
        builder: (BuildContext _context) {
          return (auth.user != null)
            ? StreamBuilder<User>(
                stream: provider.getUser(auth.user.uid),
                builder: (BuildContext _context, snapshot) {
                  var user = snapshot.data;
                  if (snapshot.hasData) {
                    var strategy = _getMenuItemsStrategy(provider, user);
                    _menuItems = strategy.render(provider, user: user);
                    return ListView(children: _menuItems);
                  } else {
                    return ListView(children: _menuItems);
                  }              
                },
              )
            : ListView(children: _menuItems);
        },
      ),
    );
  }

  MenuRenderStrategy _getMenuItemsStrategy(HomePageProvider provider, User user) {
    switch(user.role) {
      case "user": return UserMenuRenderStrategy(_deviceHeight, _deviceWidth);
      case "dealer": return DealerMenuRenderStrategy(_deviceHeight, _deviceWidth);
      case "employee": return EmployeeMenuRenderStrategy(_deviceHeight, _deviceWidth);
      default: return DefaultMenuRenderStrategy(_deviceHeight, _deviceWidth);
    }
  }
}

class DefaultMenuRenderStrategy extends MenuRenderStrategy {
  DefaultMenuRenderStrategy(double height, double width) : super(deviceHeight: height, deviceWidth: width);

  @override
  List<Widget> render(HomePageProvider provider, {User user}) {  
    List<Widget> items = [];
    items.add(getDefaultDrawerItem());
    items.addAll(getCommonItems());
    items.addAll(getLanguageItems());
    items.addAll(getLoginItems());
    return items;
  }  
}

class UserMenuRenderStrategy extends MenuRenderStrategy {
  UserMenuRenderStrategy(double height, double width) : super(deviceHeight: height, deviceWidth: width);

  @override
  List<Widget> render(HomePageProvider provider, {User user}) {
    List<Widget> items = [];
    items.add(getLoggedDrawerItem(user));
    items.addAll(getCommonItems());
    items.addAll(getUserItems());
    items.addAll(getSoftwareActivationItems());
    items.addAll(getLanguageItems());
    items.addAll(getLogoutItems(provider));
    return items;
  }
}

class DealerMenuRenderStrategy extends MenuRenderStrategy {
  DealerMenuRenderStrategy(double height, double width) : super(deviceHeight: height, deviceWidth: width);

  @override
  List<Widget> render(HomePageProvider provider, {User user}) {
    List<Widget> items = [];
    items.add(getLoggedDrawerItem(user));
    items.addAll(getCommonItems());
    items.addAll(getUserItems());
    items.addAll(getDealerItems());
    items.addAll(getSoftwareActivationItems());
    items.addAll(getLanguageItems());
    items.addAll(getLogoutItems(provider));
    return items;
  }
}

class EmployeeMenuRenderStrategy extends MenuRenderStrategy {
  EmployeeMenuRenderStrategy(double height, double width) : super(deviceHeight: height, deviceWidth: width);

  @override
  List<Widget> render(HomePageProvider provider, {User user}) {
    List<Widget> items = [];
    items.add(getLoggedDrawerItem(user));
    items.addAll(getCommonItems());
    items.addAll(getUserItems());
    items.addAll(getDealerItems(isEmployee: true));
    items.addAll(getSoftwareActivationItems());
    items.addAll(getLanguageItems());
    items.addAll(getLogoutItems(provider));
    return items;
  }
}

