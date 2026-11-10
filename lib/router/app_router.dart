import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> getRoutes() {
    return {'/': (context) => const LoginScreen()};
  }
}
