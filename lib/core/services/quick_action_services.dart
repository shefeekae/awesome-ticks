import 'package:data_collection_package/screens/qr_scanner_screen.dart';
import 'package:data_collection_package/screens/single_point_update_screen/single_point_asset_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsServices {
  QuickActions quickActions = const QuickActions();

  final String searchMeter = "searchMeter";
  final String scanMeter = "scanMeter";

  void initAndSetItems(BuildContext context) {
    quickActions.initialize((String shortcutType) {
      if (shortcutType == searchMeter) {
        showSearch(
            context: context, delegate: SinglePointAssetSearchDelegate());
      } else if (shortcutType == scanMeter) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const QrScannerScreen(
            isMulipoint: false,
          ),
        ));
      }
    });

    // calling the setShortcutItems function
    setActionsItems();
  }

  // ============================================================================

  void setActionsItems() {
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: scanMeter,
        localizedTitle: 'Scan meter',
        icon: 'scanmeter',
      ),
      ShortcutItem(
        type: searchMeter,
        localizedTitle: 'Search meter',
        icon: 'searchmeter',
      ),
    ]);
  }
}
