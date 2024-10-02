import 'package:data_collection_package/data_collection_package.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UpdateDataScreen extends StatelessWidget {
  const UpdateDataScreen(
      {super.key,
      required this.latestPoints,
      this.assetName,
      this.assetType,
      this.domain,
      this.identifier,
      this.sourceId,
      });

  final List<LatestPoint> latestPoints;
  final String? assetName;
  final String? assetType;
  final String? domain;
  final String? identifier;
  final String? sourceId;

  @override
  Widget build(BuildContext context) {
    return AddDataScreen(
      latestPoints: latestPoints,
      isEdit: true,
      assetName: assetName,
      isDetails: false,
      assetType: assetType,
      domain: domain,
      identifier: identifier,
      sourceId: sourceId,
      successHandler: () {
        Navigator.of(context).pop(true);
      },
    );
  }
}
