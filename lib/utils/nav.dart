import 'package:flutter/material.dart';

class AppNav {
  static Future push(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: Tween(
              begin: const Offset(0.1, 0.1),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
