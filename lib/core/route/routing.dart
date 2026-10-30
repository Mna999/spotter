import 'package:flutter/material.dart';

class Routing {
  static const _duration = Duration(milliseconds: 320);
  static const _reverseDuration = Duration(milliseconds: 240);

  static Route<T> _buildRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: _duration,
      reverseTransitionDuration: _reverseDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Future<T?> routeReplacement<T>(Widget page, BuildContext context) =>
      Navigator.pushReplacement<T, dynamic>(context, _buildRoute<T>(page));

  static Future<T?> routePush<T>(Widget page, BuildContext context) =>
      Navigator.push<T>(context, _buildRoute<T>(page));
}
