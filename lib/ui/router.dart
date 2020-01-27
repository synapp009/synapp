import 'package:flutter/material.dart';

import '../constants.dart';
import 'views/home.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/splash.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Constants.homeRoute:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case Constants.homeRoute:
        return MaterialPageRoute(builder: (_) => HomePage(title: 'Home'));
      case Constants.loginRoute:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Constants.registerRoute:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
