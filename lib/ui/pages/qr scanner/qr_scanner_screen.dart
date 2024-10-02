import 'dart:io';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/qr_code_services.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';

class QrScannerScreen extends StatefulWidget {
  QrScannerScreen({super.key});

  static const String id = 'qr/scanner';

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;

  bool isFlashOn = false;

  final ValueNotifier<bool> barcodeScanningLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // if (WidgetsBinding.instance.lifecycleState != null) {
    //   _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    // }

    Permission.camera.status.then((value) {
      if (value.isGranted) {
        // setState(() {});
        WidgetsBinding.instance.removeObserver(this);
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Permission.camera.status.then((value) {
        if (value.isGranted) {
          setState(() {});
          WidgetsBinding.instance.removeObserver(this);
        }
      });
    }

    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: PermissionChecking(
        featureGroup: "assetManagement",
        feature: "dashboard",
        permission: "view",
        showNoAccessWidget: true,
        paddingTop: 80.sp,
        child: FutureBuilder(
            future: Permission.camera.request(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingIosAndroidWidget(),
                );
              }

              PermissionStatus status = snapshot.data!;

              if (status.isDenied || status.isPermanentlyDenied) {
                return Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.c,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        "Camera access is turned off",
                        style: TextStyle(
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(
                        height: 10.sp,
                      ),
                      Center(
                        child: Text(
                          "Turn on camera permission to access the QR code scanner.",
                          style: TextStyle(
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // SizedBox(
                      //   height: 20.sp,
                      // ),
                      buildPermissionRetrybutton(status),
                      SizedBox(
                        height: 10.sp,
                      ),
                      // buildUploadGalleryButton(),
                    ],
                  ),
                );
              }

              return ValueListenableBuilder(
                  valueListenable: barcodeScanningLoading,
                  builder: (context, loading, child) {
                    return Stack(
                      children: [
                        QRView(
                          key: qrKey,
                          overlay: QrScannerOverlayShape(
                            borderColor: Theme.of(context).primaryColor,
                            // overlayColor: Colors.white30,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: 75.w,
                            cutOutBottomOffset: 80.sp,
                          ),
                          onQRViewCreated: (controller) async {
                            // print("onQRViewCreated $value");

                            // if (loading) {
                            //   return;
                            // }

                            controller.scannedDataStream.listen((value) {
                              // print("Scanned data : ${value.code}");

                              if (value.code != null) {
                                controller.pauseCamera();

                                QrCodeServices().handleDataFromQrCode(
                                  data: value.code!,
                                  controller: controller,
                                  context: context,
                                  barcodeScanningLoading:
                                      barcodeScanningLoading,
                                );

                                // String key = "Q6C0D3";

                                // var decrypted = EncryptionDecryptionServices()
                                //     .decryptAESCryptoJS(value.code!, key);

                                // print("DECRYPTED : $decrypted");

                                // if (decrypted == null) {
                                //   buildSnackBar(
                                //     context: context,
                                //     value: "Qr code note valid",
                                //   );
                                //   controller.resumeCamera();
                                //   return;
                                // }

                                // Navigator.of(context)
                                //     .pushNamed(AssetDetailsScreen.id, arguments: {
                                //   "identifier": decrypted,
                                // }).whenComplete(() {
                                //   controller.resumeCamera();
                                // });
                              }
                            });
                            this.controller = controller;
                          },
                        ),
                        Positioned.fill(
                          bottom: 30.h,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: buildUploadGalleryButton(),
                          ),
                        ),
                        buildFlashLightButton(),
                      ],
                    );
                  });
            }),
      ),
    );
  }

  ElevatedButton buildPermissionRetrybutton(PermissionStatus status) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 30.sp),
        shape: StadiumBorder(),
      ),
      onPressed: () async {
        // var status = await Permission.camera.status;

        if (status.isDenied) {
          Permission.camera.request().whenComplete(() {
            setState(() {});
          });
        } else {
          openAppSettings();
        }
        // setState(() {});
      },
      child: Text(
        "Tap to turn on",
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // =========================================================================================================
  //

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  // ==============================================================================================
  // Used to upload qr code image from gallery.

  // ======================================================================================================

  // Widget buildUploadGalleryButton() {
  //   return BuildUploadGalleryButton();
  // }

  // ============================================================================
  // Build Flash light button.

  Positioned buildFlashLightButton() {
    return Positioned(
      // textDirection: TextDirection.rtl,
      bottom: 20.sp,
      right: 20.sp,
      // left: 50.w,
      child: StatefulBuilder(builder: (context, setState) {
        return FloatingActionButton(
          onPressed: () {
            controller?.toggleFlash();
            setState(() {
              isFlashOn = !isFlashOn;
            });
          },
          child: Icon(
            isFlashOn
                ? Icons.flashlight_off_outlined
                : Icons.flashlight_on_outlined,
          ),
        );
      }),
    );
  }

  Widget buildUploadGalleryButton() {
    return Builder(builder: (context) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.sp),
          ),
        ),
        icon: Icon(
          Icons.image,
          size: 12.sp,
          // color: primaryColor,
        ),
        onPressed: () async {
          bool isAndroid = Platform.isAndroid;

          PermissionStatus permissionStatus = isAndroid
              ? await Permission.storage.request()
              : await Permission.photos.request();

          if (permissionStatus.isPermanentlyDenied) {
            // ignore: use_build_context_synchronously
            buildSnackBar(
                context: context,
                value: "Grant permission to access gallery",
                snackBarAction: SnackBarAction(
                    label: "Enable",
                    onPressed: () {
                      openAppSettings();
                    }));
            // print(permissionStatus);

            // Permission.camera.request();
          } else if (permissionStatus.isDenied) {
            PermissionStatus permissionStatus = isAndroid
                ? await Permission.storage.status
                : await Permission.photos.status;

            if (permissionStatus.isGranted) {
              var file =
                  // ignore: use_build_context_synchronously
                  await FileServices().pickImage(
                context,
              );

              if (file != null) {
                // ignore: use_build_context_synchronously
                QrCodeServices().parseImageQr(
                    filePath: file.path,
                    context: context,
                    controller: controller!,
                    barcodeScanningLoading: barcodeScanningLoading);
              }
            } else if (permissionStatus.isPermanentlyDenied ||
                permissionStatus.isDenied) {
              // ignore: use_build_context_synchronously
              buildSnackBar(
                context: context,
                value: "Grant permission to access gallery",
                snackBarAction: SnackBarAction(
                  label: "Enable",
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              );
            }
          } else {
            // ignore: use_build_context_synchronously

            // ignore: use_build_context_synchronously
            var file = await FileServices().pickImage(
              context,
            );

            if (file != null) {
              // var file = files[0];
              // ignore: use_build_context_synchronously
              QrCodeServices().parseImageQr(
                  filePath: file.path,
                  context: context,
                  controller: controller!,
                  barcodeScanningLoading: barcodeScanningLoading);
            }
          }
        },
        label: Text(
          "Upload from gallery",
          style: TextStyle(
            fontSize: 10.sp,
            // color: primaryColor,
          ),
        ),
      );
    });
  }
}
