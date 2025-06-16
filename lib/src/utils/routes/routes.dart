import 'package:flutter/material.dart';

import '../../ui/pages/homePage.dart';
import '../../ui/pages/loginPage.dart';
import 'route_names.dart';

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;

  _GeneratePageRoute({
    required this.widget,
    required this.routeName
  })
      : super(
      settings: RouteSettings(name: routeName),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return widget;
      },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      });
}


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RouteNames.loginPage:
        return _GeneratePageRoute(
            widget: const LoginPage(), routeName: settings.name!);
      case RouteNames.homePage:
        return _GeneratePageRoute(
            widget: const HomePage(), routeName: settings.name!);
      default:
        return _GeneratePageRoute(
            widget: const LoginPage(), routeName: settings.name!);
    }
  }
}