import 'package:flutter/material.dart';

class DialogActionModel {
  Widget child;
  void Function()? onPressed;
  DialogActionModel({
    required this.child,
    this.onPressed,
  });
}
