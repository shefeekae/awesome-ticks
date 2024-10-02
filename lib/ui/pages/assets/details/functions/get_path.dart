// ========================================================================================
// This method is used to get the source tag path of alarm.

  import '../../../../../core/models/assets/assets_list_model.dart';

String getPath({required List list}) {
    String sourceTagPath = "";

    for (var index = 0; index < list.length; index++) {
      String name = list[index]['name'];
      sourceTagPath = index == 0 ? name : "$sourceTagPath  -  $name";
    }
    return sourceTagPath;
  }


  // ======================================================================

//   getAssetPath(List<Path> path){
//  String sourceTagPath = "";

//     for (var index = 0; index < path.length; index++) {
//       String name = path[index].
//       sourceTagPath = index == 0 ? name : "$sourceTagPath  -  $name";
//     }
//     return sourceTagPath;



    

//   }