import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Color defaultAccent= HexColor("#FFB955");
// HexColor("#ce8057");

// Color Theme.of(context).primaryColor = HexColor("#174E48");
Color secondaryAlt = HexColor("#23756c");
//  Color.fromRGBO(16, 27, 45, 1);

Color fwhite = HexColor("#f1f1f1");

const Color kWhite = Colors.white;

Color kBlack = Colors.black;

// Color primaryAlt = HexColor("#ffefcd");

// List<Color> gradientColors = [
//   Theme.of(context).primaryColor,
//   secondaryAlt,
// ];

LinearGradient getGradientColors(
  BuildContext context, {
  Alignment begin = Alignment.center,
  Alignment end = Alignment.bottomCenter,
}) {
  return LinearGradient(
    colors: [
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).primaryColor,
    ],
    begin: begin,
    end: end,
  );
}
