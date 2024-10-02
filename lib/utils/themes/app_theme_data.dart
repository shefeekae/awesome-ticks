import 'dart:convert';

import 'package:awesometicks/core/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:secure_storage/secure_storage.dart';

import '../../ui/shared/functions/get_material_color.dart';
import 'colors.dart';

class AppThemeData {
 final ThemeServices themeServices = ThemeServices();

  ThemeData getThemeData() {
    String? data = SharedPrefrencesServices().getData(key: "appTheme");

    Map appTheme = data == null ? {} : jsonDecode(data);

    Color? savedPrimary =
        appTheme['primary'] == null ? null : HexColor(appTheme['primary']);
    Color? savedSecondary =
        appTheme['secondary'] == null ? null : HexColor(appTheme['secondary']);

    Color? savedAccent =
        appTheme['accent'] == null ? null : HexColor(appTheme['accent']);

    Color primaryFgColor =
        themeServices.isLightColor(savedPrimary ?? HexColor("#174E48"))
            ? kBlack
            : kWhite;

    Color primaryColor = savedPrimary ?? HexColor("#174E48");

    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(
        seedColor: savedPrimary ?? HexColor("#174E48"),
        secondary: savedAccent ?? defaultAccent,
        secondaryContainer: savedSecondary ?? HexColor("#23756c"),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: savedPrimary ?? HexColor("#174E48"),
        foregroundColor: primaryFgColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryFgColor,
        ),
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
      primaryIconTheme: IconThemeData(
        color: primaryColor,
      ),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: defaultAccent,
      ),
      scaffoldBackgroundColor: fwhite,
      appBarTheme: AppBarTheme(
        backgroundColor: savedPrimary ?? HexColor("#174E48"),
        foregroundColor: primaryFgColor,
        iconTheme: IconThemeData(
          color: primaryFgColor,
        ),
        actionsIconTheme: IconThemeData(
          color: primaryFgColor,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      primaryColor: savedPrimary ?? HexColor("#174E48"),
      primarySwatch: buildMaterialColor(
        savedPrimary ?? HexColor("#174E48"),
      ),
    );
  }
}
