// ignore_for_file: public_member_api_docs, sort_constructors_first
class WKTServices {
  bool isWKTFormat(String text) {
    // Regular expression pattern for WKT format validation
    const pattern =
        r'^\s*(POINT|LINESTRING|POLYGON|MULTIPOINT|MULTILINESTRING|MULTIPOLYGON|GEOMETRYCOLLECTION)\s*\([^\)]*\)\s*$';
    final regex = RegExp(pattern, caseSensitive: false);
    return regex.hasMatch(text);
  }

  // ============================================================
  // Parse the wkt point

  LatLng parseWktPoint(String wktPoint) {
    List<String> coords =
        wktPoint.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    double lng = double.parse(coords[0]);
    double lat = double.parse(coords[1]);
    return LatLng(latitude: lat, longitude: lng);
  }
}

class LatLng {
  final double latitude;
  final double longitude;
  LatLng({
    required this.latitude,
    required this.longitude,
  });
}
