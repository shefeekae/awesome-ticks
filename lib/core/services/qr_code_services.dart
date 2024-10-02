import 'package:awesometicks/core/services/assets_services.dart';
import 'package:awesometicks/core/services/encryption_decryption_services.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_utils/qr_code_utils.dart';
import '../../ui/shared/widgets/custom_snackbar.dart';

class QrCodeServices {
// ==============================================================================================

  void handleDataFromQrCode({
    required String data,
    required QRViewController? controller,
    required BuildContext context,
    required ValueNotifier<bool> barcodeScanningLoading,
  }) {
    if (barcodeScanningLoading.value) {
      if (controller != null) {
        controller.pauseCamera();
      }
      return;
    }

    String key = "Q6C0D3";

    var decrypted =
        EncryptionDecryptionServices().decryptAESCryptoJS(data, key);

    if (decrypted == null) {
      buildSnackBar(
        context: context,
        value: "Qr code not valid",
      );
      if (controller != null) {
        controller.resumeCamera();
      }
      barcodeScanningLoading.value = false;

      return;
    }

    barcodeScanningLoading.value = true;

    AssetServices().getAssetEntityData(
        value: decrypted,
        context: context,
        controller: controller!,
        barcodeScanningLoading: barcodeScanningLoading);

    // Navigator.of(context).pushNamed(AssetDetailsScreen.id, arguments: {
    //   "identifier": decrypted,
    // }).whenComplete(() {
    //   if (controller != null) {
    //     controller.resumeCamera();
    //   }
    // });
  }

// ==========================================================================

// ==================================================================================================
//   Parse data from image qr

  parseImageQr({
    required String filePath,
    required BuildContext context,
    required QRViewController controller,
    required ValueNotifier<bool> barcodeScanningLoading,
  }) async {
    try {
      String? data = await QrCodeUtils.decodeFrom(filePath);
      if (data == null) {
        // ignore: use_build_context_synchronously
        buildSnackBar(
          context: context,
          value: "Unable to recognize a valid code from uploaded image",
        );
        return;
      }
      // ignore: use_build_context_synchronously
      handleDataFromQrCode(
        data: data,
        controller: controller,
        context: context,
        barcodeScanningLoading: barcodeScanningLoading,
      );
    } catch (e) {
      buildSnackBar(
        context: context,
        value: "Unable to recognize a valid code from uploaded image",
      );
    }
  }
}
