import 'package:flutter/material.dart';

class Routing {
  static Future<void> routeReplacement(Widget page, BuildContext context) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
  static Future<void> routePush(Widget page, BuildContext context) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
}
