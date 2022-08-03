import 'package:flutter/material.dart';

class NavigationService {
  static NavigationService instance = NavigationService();
  GlobalKey<NavigatorState> navigatorKey;

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route, {bool popBackStack = false}) {
    if (popBackStack) {
      goBack();
    }
    return navigatorKey.currentState.push(_route);
  }

  Future<dynamic> navigateToRouteWithReplacement(MaterialPageRoute _route) {    
    return navigatorKey.currentState.pushAndRemoveUntil(_route, (route) => false);
  }

  Future<dynamic> navigateTo(String _routeName) {
    return navigatorKey.currentState.pushNamed(_routeName);
  }

  Future<dynamic> navigateToReplacement(String _routeName) {
    return navigatorKey.currentState.pushReplacementNamed(_routeName);
  }

  void goBack({dynamic result = ""}) {
    return navigatorKey.currentState.pop(result);
  }
}