import 'package:flutter/material.dart';

IconData getActionButtonIcon(String key) {
  switch (key) {
    case "start":
      return Icons.play_arrow;

    case "cancel":
      return Icons.close;

    case "hold":
      return Icons.pause;

    case "complete":
      return Icons.done;
    default:
      return Icons.abc;
  }
}
