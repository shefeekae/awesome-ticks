import 'dart:convert';
import 'dart:io';
// import 'package:dio/dio.dart';
import 'package:awesometicks/core/services/mime_types.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../../ui/pages/service request/details/service_details.dart';
import '../../../ui/shared/widgets/custom_snackbar.dart';
import '../../schemas/service_request_schemas.dart';
import '../graphql_services.dart';

class ServiceRequstServices {
  // ============================================================================
  GraphqlServices graphqlServices = GraphqlServices();
  // =============================================================================

  UserDataSingleton userData = UserDataSingleton();

  void manageServiceRequestResult({
    required BuildContext context,
    // required Map<String, dynamic> variables,
    required File? file,
    required bool isEdit,
    required Map<String,dynamic> data,
    required ValueNotifier serviceRequestNotifier,
    String? moveInRequestNumber,
  }) async {
    // List<MultipartFile> list = [];
    // Map<String, dynamic> map = {};

    // var result = await graphqlServices.performMutation(
    //   query: ServiceRequestSchemas.saveServiceRequestMutation,
    //   variables: variables,
    // );

    // if (result.hasException) {
    //   print(result.exception);
    //   // ignore: use_build_context_synchronously
    //   buildSnackBar(
    //     context: context,
    //     value: "Something went wrong. Please try again.",
    //   );
    //   return;
    // }

    // print("CREATED Service ${result.data}");

    // ServiceDetailsModel serviceDetailsModel =
    //     ServiceDetailsModel.fromJson(result.data!);

    String? requestNumber =
        data['saveServiceRequest']?['requestNumber'];
    // serviceDetailsModel.findServiceRequest?.requestNumber;

    if (requestNumber == null) {
      // ignore: use_build_context_synchronously
      buildSnackBar(
        context: context,
        value: "Service creation failed",
      );
      return;
    }

    if (file != null) {
      serviceRequestNotifier.value = true;
      await attachFiles(
        context: context,
        attachedFile: file,
        requestNumber: requestNumber,
      );
      serviceRequestNotifier.value = false;
    }

    if (isEdit) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context)
        .pushReplacementNamed(ServiceDetailsScreen.id, arguments: {
      "requestNumber": requestNumber,
    });

    // serviceRequestNotifier.value = false;

    // if (moveInRequestNumber != null) {
    //   Box<PremiseModel> box = PremiseModel.getPremiseBox();

    //   List<PremiseModel> premises = box.values.toList();

    //   int index = premises.indexWhere(
    //       (element) => element.details['requestNumber'] == moveInRequestNumber);

    //   if (index != -1) {
    //     box.putAt(
    //       index,
    //       PremiseModel(
    //         userId: userId,
    //         details: premises[index].details,
    //         success: true,
    //       ),
    //     );
    //     // ignore: use_build_context_synchronously
    //     Navigator.of(context).pushNamedAndRemoveUntil(
    //       HomeScreen.id,
    //       (route) => false,
    //     );

    //     return;
    //   }
    // }
    // ignore: use_build_context_synchronously
  }

// -------------------------------------------------
// AttachFiles

  Future<void> attachFiles({
    required File attachedFile,
    required String requestNumber,
    required BuildContext context,
  }) async {
    var byteData = await attachedFile.readAsBytes();

    // var documentary = await getApplicationDocumentsDirectory();

    String fileName = path.basename(attachedFile.path);
    String extension = attachedFile.path.split('.').last;

    String mimeType = MimeTypes.getMimeType(extension);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      byteData,
      filename: fileName,
      contentType: MediaType(mimeType.split('/').first, extension),
    );

    String domain = userData.domain;

    // ignore: use_build_context_synchronously
    var result = await GraphqlServices().performMutation(
      context: context,
      operationName: "uploadMultipleFiles",
      query: ServiceRequestSchemas.uploadMultipleFilesMutation,
      variables: {
        "data": [
          {
            "file": multipartFile,
            "name": fileName,
            "filePath": "serviceRequests/$domain/$requestNumber",
          },
        ],
      },
    );

    if (result.hasException) {
      print("exception called");
      print(result.exception);
      return;
    }

    print(result.data);
  }

  // ==================================================================================
  // getAttached filesh.

  // Future<File?> getImages(
  //   BuildContext context, {
  //   bool isCamera = false,
  // }) async {
  //   final ImagePicker picker = ImagePicker();

  //   if (isCamera) {
  //     XFile? xFile = await picker.pickImage(
  //       source: ImageSource.camera,
  //     );

  //     if (xFile == null) {
  //       return null;
  //     }

  //     return File(xFile.path);
  //   }

  //   XFile? xFile;
  //   try {
  //     xFile = await picker.pickImage(source: ImageSource.gallery);
  //   } catch (e) {
  //     print("getImages catchbloc called");
  //     print(e);
  //   }

  //   if (xFile == null) {
  //     return null;
  //   }

  //   return File(xFile.path);
  // }

//  ====================================================================================================
// Get video file.

  Future<File?> getVideo(
    BuildContext context, {
    bool isCamera = false,
  }) async {
    final ImagePicker picker = ImagePicker();

    if (isCamera) {
      XFile? xFile = await picker.pickVideo(
        source: ImageSource.camera,
      );

      if (xFile == null) {
        return null;
      }

      return File(xFile.path);
    }

    XFile? xFile;
    try {
      xFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );
    } catch (e) {
      print("getImages catchbloc called");
      print(e);
    }

    if (xFile == null) {
      return null;
    }

    return File(xFile.path);
  }

//  ================================================================================
// decrypt data;

  Future<List<Map>> decryptFiles({
    required List list,
  }) async {
    List<Map> filesMap = [];

    for (var element in list) {
      String base64Encoded = element['data'];
      String fileName = element['fileName'] ?? "";

      print("fileName $fileName");

      Uint8List decodedbytes = base64Decode(base64Encoded);

      final directory = await getApplicationDocumentsDirectory();

      File file =
          await File("${directory.path}/$fileName").writeAsBytes(decodedbytes);
      // files.add(file);
      filesMap.add({
        "file": file,
        "fileName": fileName,
      });
    }

    return filesMap;
  }

  // ================================================================================================
  // Checking the file is video.

  bool isFileVideo(String path) {
    final List<String> videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      // Add more video extensions as needed
    ];

    String extension = path.split('.').last.toLowerCase();
    return videoExtensions.contains('.$extension');
  }
}
