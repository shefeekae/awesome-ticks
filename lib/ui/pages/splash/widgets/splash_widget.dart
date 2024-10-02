import 'dart:convert';
import 'dart:io';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:sizer/sizer.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String? appLogo = SharedPrefrencesServices().getData(key: "appLogo");

    var logoData = appLogo == null ? {} : jsonDecode(appLogo);

    return Container(
      decoration: BoxDecoration(
        gradient: getGradientColors(
          context,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Builder(builder: (context) {
                  String? data = logoData?['data'];
                  String? extension = logoData?['extension'];

                  if (data != null) {
                    File file = File(data);

                    if (!file.existsSync()) {
                      return buildDefaultLogo();
                    }

                    if (extension == ".svg") {
                      return SvgPicture.file(
                        file,
                        width: 50.w,
                      );
                    }

                    return Image.file(
                      file,
                      width: 50.w,
                    );
                  }

                  return buildDefaultLogo();
                }),
                Builder(builder: (context) {
                  String? appTheme =
                      SharedPrefrencesServices().getData(key: "appTheme");

                  Map<String, dynamic>? data =
                      appTheme == null ? null : jsonDecode(appTheme);

                  String? name = data?['name'];

                  return Text(
                    name ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
                const Spacer(),
                Text(
                  "Powered By Nectar",
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  // =======================================================================================
  // Showing the default logo.

  Hero buildDefaultLogo() {
    return Hero(
      tag: "logo",
      transitionOnUserGestures: true,
      child: SvgPicture.asset(
        "assets/images/nectar-logo (1).svg",
        width: 50.w,
      ),
    );
  }
}
