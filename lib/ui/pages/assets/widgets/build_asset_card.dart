import 'package:awesometicks/core/models/assets/assets_list_model.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/ui/pages/assets/details/asset_details_screen.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:sizer/sizer.dart';
import '../details/functions/get_path.dart';
import '../details/widgets/alarm_card.dart';

class BuildAssetCard extends StatelessWidget {
  const BuildAssetCard({
    super.key,
    // required this.alarmStatsList,
    required this.asset,
  });

  final Assets asset;

  final double borderRadius = 7;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 100),
      onPressed: () {
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
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.displayName ?? "N/A",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: kBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.sp,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.sp, horizontal: 5.sp),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(7.sp),
                    ),
                    child: Text(
                      asset.typeName ?? "N/A",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.sp,
                        // color: kBlack,
                        color: ThemeServices().getPrimaryFgColor(context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Builder(builder: (context) {
              List list = asset.path?.map((e) => e.toJson()).toList() ?? [];

              return Visibility(
                visible: list.isNotEmpty,
                child: BuildAssetPathFooter(
                  context: context,
                  borderRadius: borderRadius,
                  assetPath: getPath(
                    list: list,
                  ),
                ),
              );
            })
            // buildFooter()
          ],
        ),
      ),
    );
  }
}
