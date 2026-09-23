import 'package:flutter/material.dart';
import '../views/login_view.dart';

class AppRouter {
  static Map<String, WidgetBuilder> getRoutes() {
    return {'/': (context) => const LoginView()};
  }
}