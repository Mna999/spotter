import 'package:flutter/material.dart';

class SnackBarBuilder {
  static void showSnackBar(
    BuildContext context,
    String message,
    bool isError,
    ColorScheme cs,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? cs.onError : cs.primaryContainer,
      ),
    );
  }
}
