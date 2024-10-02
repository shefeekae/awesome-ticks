import 'dart:convert';

import 'package:app_filter_form/core/services/form_filter_enum.dart';
import 'package:app_filter_form/widgets/form_widget.dart';
import 'package:awesometicks/core/models/list_service_request_model.dart';
import 'package:awesometicks/ui/pages/service%20request/details/service_details.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AssetServiceRequestFormWidget extends StatelessWidget {
  const AssetServiceRequestFormWidget(
      {super.key, required this.assetData});

  final Map<String, dynamic> assetData;


  @override
  Widget build(BuildContext context) {
    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    bool restrictConvertSrToJob = false;

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      restrictConvertSrToJob =
          data?["jobConfiguration"]?["restrictConvertSrToJob"] ?? false;
    }

    return Scaffold(
      // backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text('Create Service Request'),
        centerTitle: true,
      ),
      body: FormWidget(
        isMobile: true,
        formType: FormType.serviceRequest,
        initialValues: [
          {
            "key": "resource",
            "identifier": assetData,
            "values": [
              {
                "name": assetData['data']['displayName'],
                "data": jsonEncode(assetData),
              }
            ]
          },
        ],
        isEdit: false,
        editPayload: {
          "requestTime": DateTime.now().millisecondsSinceEpoch,
          "requestStatus": "OPEN",
          "convertToJob": !restrictConvertSrToJob,
          "resource": {
            "type": assetData["type"],
            "domain": assetData["data"]["domain"],
            "resourceId": assetData["data"]["identifier"],
          }
        },
        saveSuccessHandler: (arguments) {
          Navigator.of(context).pushReplacementNamed(
            ServiceDetailsScreen.id,
            arguments: arguments,
          );
        },
      ),
    );
  }
}
