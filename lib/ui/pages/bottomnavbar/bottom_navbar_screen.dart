import 'dart:io';
import 'package:awesometicks/core/services/quick_action_services.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/ui/pages/assets/search/search_assets.dart';
import 'package:awesometicks/ui/pages/calendar/job_calendar.dart';
import 'package:awesometicks/ui/pages/home/home_screen.dart';
import 'package:awesometicks/ui/pages/profile/profile_screen.dart';
import 'package:awesometicks/ui/pages/qr%20scanner/qr_scanner_screen.dart';
import 'package:awesometicks/ui/pages/service%20request/create_service_request.dart';
import 'package:awesometicks/ui/pages/service%20request/list/service_list_screen.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:data_collection_package/screens/single_point_update_screen/widgets/update_point_bottomsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/user_permission.dart';
import '../../../core/services/syncing_services.dart';

class BottomNavBarScreen extends StatefulWidget {
  BottomNavBarScreen({super.key});

  static String id = "/bottomnavbar";

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}




class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  // ValueNotifier valueNotifier = ValueNotifier(0);
  final List<Map> items = [
    {
      "title": "Home",
      "page": const HomeScreen(),
      "icon": Icons.home,
      "key": "home",
    },
    {
      "title": "Calendar",
      "page": const JobCalendarScreen(),
      "icon": Icons.calendar_month,
      "key": "calendar",
    },
    {
      "title": "Scan QR",
      "page": QrScannerScreen(),
      "icon": Icons.qr_code_scanner,
      "key": "scan",
    },
    {
      "title": "Services",
      "page": const ServiceListScreen(),
      "icon": Icons.support_agent,
      "key": "services",
    },
    {
      "title": "Profile",
      "page": ProfileScreen(),
      "icon": Icons.person,
      "key": "profile",
    },
  ];

  int selectedIndex = 0;

  final UserPermissionServices userPermissionServices =
      UserPermissionServices();

  @override
  void initState() {
    // SyncingServices().listenForInternet(context);
    
        QuickActionsServices().initAndSetItems(context);


    bool jobsPermission = userPermissionServices.checkingPermission(
      featureGroup: "jobManagement",
      feature: "job",
      permission: "list",
    );

    bool serviceRequestsPermission = userPermissionServices.checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "list",
    );

    bool scannerPermission = userPermissionServices.checkingPermission(
      featureGroup: "assetManagement",
      feature: "dashboard",
      permission: "view",
    );

    if (!jobsPermission) {
      items.removeWhere((element) => element['key'] == "home");
      items.removeWhere((element) => element['key'] == "calendar");
    }

    if (!serviceRequestsPermission) {
      items.removeWhere((element) => element['key'] == "services");
    }

    if (!scannerPermission) {
      items.removeWhere((element) => element['key'] == "scan");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        floatingActionButton: items[selectedIndex]['key'] == "scan"
            ? null
            : buildSpeedDialButton(),
        // FloatingActionButton(
        //     onPressed: () {
        //       Navigator.of(context)
        //           .pushNamed(AssetDetailsScreen.id, arguments: {
        //         "asset": {
        //           "type": "a",
        //           "data": {
        //             "identifier": "",
        //             "domain": "ad",
        //           }
        //         }
        //       });
        //       // Navigator.of(context).pushNamed(
        //       //   CreateOrEditServiceRequestScreen.id,
        //       // );
        //     },
        //     child: const Icon(CupertinoIcons.add),
        //   ),
        body: items[selectedIndex]['page'],
        bottomNavigationBar:
            KeyboardVisibilityBuilder(builder: (context, visible) {
          if (visible) {
            return const SizedBox();
          }
          return Container(
            // color: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
              gradient: getGradientColors(
                context,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: EdgeInsets.only(bottom: Platform.isIOS ? 10.sp : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                bool selected = index == selectedIndex;

                // Color color = selected ? primaryColor : primaryAlt;

                Color color = selected
                    ? Theme.of(context).colorScheme.secondary
                    : ThemeServices().getPrimaryFgColor(context);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 5.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10.sp,
                        ),
                        Icon(
                          items[index]['icon'],
                          color: color,
                          size: 18.sp,
                        ),
                        SizedBox(
                          height: 1.sp,
                        ),
                        Text(
                          items[index]['title'],
                          style: TextStyle(
                            color: color,
                            fontSize: 7.sp,
                            // fontWeight: selected ? FontWeight.w600 : null,
                          ),
                        ),
                        SizedBox(
                          height: 10.sp,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }));
  }

  // ======================================================================
  // Build Menu Speed Dail

  Widget buildSpeedDialButton() {
    bool isOpened = false;

    bool serviceRequiestCreatePermission =
        UserPermissionServices().checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "create",
    );

    bool assetSearchPermission = UserPermissionServices().checkingPermission(
      featureGroup: "assetManagement",
      feature: "assetList",
      permission: "list",
    );

    if (!serviceRequiestCreatePermission && !assetSearchPermission) {
      return const SizedBox();
    }

    List<SpeedDialChild> list = [];

    SpeedDialChild serviceRequestSpeedDailChild = buildSpeedChildButton(
      iconData: CupertinoIcons.add,
      key: "create_service",
      title: "Create Service Request",
    );

    SpeedDialChild assetSearchspeedDialChild = buildSpeedChildButton(
      iconData: CupertinoIcons.search,
      key: "asset_search",
      title: "Search Assets",
    );

    SpeedDialChild updateMeterSpeedDialChild = buildSpeedChildButton(
      iconData: Icons.speed_rounded,
      key: "update_meter",
      title: "Update Meter",
    );

    if (serviceRequiestCreatePermission) {
      list.add(serviceRequestSpeedDailChild);
    }

    if (assetSearchPermission) {
      list.add(assetSearchspeedDialChild);
    }

    list.add(updateMeterSpeedDialChild);

    return StatefulBuilder(
      builder: (context, setState) {
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animationDuration: const Duration(milliseconds: 250),
          overlayColor: Colors.black,
          backgroundColor:
              isOpened ? Colors.red.shade700 : Theme.of(context).primaryColor,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          onOpen: () {
            setState(
              () {
                isOpened = true;
              },
            );
          },
          onClose: () {
            setState(
              () {
                isOpened = false;
              },
            );
          },
          spacing: 10.sp,
          spaceBetweenChildren: 5.sp,
          children: list,
        );
      },
    );
  }

// ========================================================================
// Speed child button.

  SpeedDialChild buildSpeedChildButton({
    required IconData iconData,
    required String key,
    required String title,
  }) {
    return SpeedDialChild(
      child: Icon(
        iconData,
      ),
      label: title,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor:
          Theme.of(context).floatingActionButtonTheme.foregroundColor,
      onTap: () {
        switch (key) {
          case "asset_search":
            showSearch(
              context: context,
              delegate: AssetsSearchDelegate(),
            );
            break;

          case "create_service":
            Navigator.of(context).pushNamed(
              CreateOrEditServiceRequestScreen.id,
            );
            break;

          case "update_meter":
            singlePointBottomSheet(context);
            break;

          default:
        }
      },
    );
  }
}
