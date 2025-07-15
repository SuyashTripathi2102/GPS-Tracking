import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.blue);
  }

  static void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
