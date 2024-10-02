import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';

class ThemeServices {
  bool isLightColor(Color color) {
    // Calculate the luminance of the color
    final luminance = color.computeLuminance();

    // Determine the threshold for considering a color as light or dark
    // You can adjust this threshold as needed
    final threshold = 0.5;

    // Compare the luminance with the threshold
    return luminance > threshold;
  }

  Color getPrimaryFgColor(BuildContext context) {
    return isLightColor(Theme.of(context).primaryColor) ? kBlack : kWhite;
  }

  Color getSecondaryFgColor(BuildContext context) {
    return isLightColor(Theme.of(context).colorScheme.secondary) ? kBlack : kWhite;
  }

  


}
