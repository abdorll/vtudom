import 'package:flutter/material.dart';

class AppRoutes {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "":
        return screenOf(screenName: Container());
      default:
        return screenOf(screenName: Container());
    }
  }
}

MaterialPageRoute screenOf({required Widget screenName}) {
  return MaterialPageRoute(builder: (context) => screenName);
}
