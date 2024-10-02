import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherServices {
  bool isWKTFormat(String text) {
    // Regular expression pattern for WKT format validation
    const pattern =
        r'^\s*(POINT|LINESTRING|POLYGON|MULTIPOINT|MULTILINESTRING|MULTIPOLYGON|GEOMETRYCOLLECTION)\s*\([^\)]*\)\s*$';
    final regex = RegExp(pattern, caseSensitive: false);
    return regex.hasMatch(text);
  }

  void openGoogleMaps(BuildContext context, String? location) async {
    // The coordinates of the location you want to open in Google Maps

    print("Location is $location");

    if (location == null) {
      buildSnackBar(context: context, value: "Location not found");
      return;
    }

    if (!isWKTFormat(location)) {
      buildSnackBar(context: context, value: " not found");

      return;
    }

    List<String> coords =
        location.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    double lng = double.parse(coords[0]);
    double lat = double.parse(coords[1]);

    // Create the Google Maps URL
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    // Check if the URL can be launched
    if (await canLaunch(googleMapsUrl)) {
      // Launch the URL
      await launch(googleMapsUrl);
    } else {
      // Handle the error
      // throw 'Could not launch $googleMapsUrl';
      // ignore: use_build_context_synchronously
      buildSnackBar(context: context, value: "Can't open map this time.");
    }
  }

  Future<void> launchPhoneDialer(
      BuildContext context, String? contactNumber) async {
    if (contactNumber == null) {
      return;
    }
    final Uri phoneUri = Uri(scheme: "tel", path: contactNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!context.mounted) return;
        buildSnackBar(
          context: context,
          value: "Can't open caller app this time.",
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      buildSnackBar(context: context, value: "Cannot dial");
    }
  }
}
