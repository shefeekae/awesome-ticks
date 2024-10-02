import 'package:secure_storage/secure_storage.dart';
import 'package:awesometicks/ui/pages/assets/details/asset_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../ui/shared/widgets/custom_snackbar.dart';
import '../models/assets/assets_list_model.dart';
import '../schemas/assets_schemas.dart';
import 'graphql_services.dart';

class AssetServices {
  // =============================================================
  // ============================================================

  UserDataSingleton userData = UserDataSingleton();

  void getAssetEntityData({
    required String value,
    required BuildContext context,
    required QRViewController controller,
    required ValueNotifier<bool> barcodeScanningLoading,
  }) async {
    var result = await GraphqlServices().performQuery(
      query: AssetSchema.getAssetList,
      variables: {
        "filter": {
          "identifier": value,
          "searchLabel": "",
          // "offset": 1,
          // "pageSize": 10,
          "clients": userData.domain,
        }
      },
    );

    if (result.hasException) {
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          barcodeScanningLoading.value = false;
        },
      );

      // ignore: use_build_context_synchronously
      buildSnackBar(context: context, value: "Something went wrong");
      controller.resumeCamera();
      return;
    }

    AssetsListModel assetsListModel = AssetsListModel.fromJson(result.data!);

    List<Assets>? assets = assetsListModel.getAssetList?.assets;

    if (assets == null) {
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          barcodeScanningLoading.value = false;
        },
      );
      // hanlding the exception
      if (context.mounted) {
        buildSnackBar(
          context: context,
          value: "Something went wrong. Please Try again",
        );
      }
      return;
    }

    // if (assets != null) {
    if (assets.isNotEmpty) {
      Assets asset = assets.first;

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(
        AssetDetailsScreen.id,
        arguments: {
          "name": asset.displayName,
          "asset": {
            "type": asset.type,
            "data": {
              "identifier": asset.identifier,
              "domain": asset.domain,
            }
          },
        },
      ).whenComplete(() {
        controller.resumeCamera();
        barcodeScanningLoading.value = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      buildSnackBar(context: context, value: "Asset not found.");
      controller.resumeCamera();
      barcodeScanningLoading.value = false;
    }
  }
}
// }
