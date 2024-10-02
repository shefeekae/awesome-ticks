import 'package:flutter/material.dart';

void buildSnackBar({
  required BuildContext context,
  required String value,
  SnackBarBehavior snackBarBehavior = SnackBarBehavior.floating,
  SnackBarAction? snackBarAction,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
  
    SnackBar(
      behavior: snackBarBehavior,
      content: Text(value),
      action: snackBarAction,
    ),
  );
}
