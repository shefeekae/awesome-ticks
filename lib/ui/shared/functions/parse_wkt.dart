
// // ============================================================
// // Parse the wkt point

//   LatLng parseWktPoint(String wktPoint) {
//     List<String> coords =
//         wktPoint.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
//     double lng = double.parse(coords[0]);
//     double lat = double.parse(coords[1]);
//     return LatLng(lat, lng);
//   }