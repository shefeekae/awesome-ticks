import 'package:awesometicks/core/models/assets/asset_info_model.dart';
import 'package:awesometicks/ui/pages/assets/details/functions/get_path.dart';
import 'package:intl/intl.dart';

List getAssetsInfoList({
  required AssetLatest? assetLatest,
  required AssetData? assetData,
}) {
  // double? runHours = assetInfoModel.findAsset?.settings?.runhours;

  // int? createdON = assetData?.createdOn;

  int? lastCommunicated = assetLatest?.dataTime;

  int? onBoarded = assetLatest?.createdOn;

  String lastCommunicatedDate = lastCommunicated == null
      ? ""
      : DateFormat("dd-MMM-yyyy").add_jm().format(
            DateTime.fromMillisecondsSinceEpoch(
              lastCommunicated,
            ),
          );

  String onBoardedDate = onBoarded == null
      ? ""
      : DateFormat("dd-MMM-yyyy").add_jm().format(
            DateTime.fromMillisecondsSinceEpoch(
              onBoarded,
            ),
          );

  String locationPath = assetLatest?.path == null
      ? ""
      : getPath(list: assetLatest!.path!.map((e) => e.toJson()).toList());

  return [
    {
      "title": "Name",
      "value": assetData?.displayName ?? "",
    },
    {
      "title": "Type",
      "value": assetData?.typeName ?? "",
    },
    {
      "title": "Location",
      "value": assetLatest?.location ?? "",
    },
    {
      "title": "Location Path",
      "value": locationPath,
    },
    {
      "title": "State",
      "value": assetData?.state ?? "",
    },
    {
      "title": "Current Status",
      "value": assetData?.status ?? "",
    },
    {
      "title": "On Boarded date",
      "value": onBoardedDate,
    },
    {
      "title": "Last communicated",
      "value": lastCommunicatedDate,
    },
  ].where((element) => element['value']!.isNotEmpty).toList();
}
