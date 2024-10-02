import 'package:awesometicks/core/models/assets/assets_list_model.dart';
import 'package:awesometicks/core/schemas/assets_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/ui/shared/functions/get_material_color.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:sizer/sizer.dart';

import 'package:secure_storage/services/shared_prefrences_services.dart';
import '../widgets/build_asset_card.dart';

class AssetsSearchDelegate extends SearchDelegate<String> {
  // final List<String> items;

  // AssetsSearchDelegate(this.items);

  UserDataSingleton userData = UserDataSingleton();

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return ThemeData(
      primaryColor: Theme.of(context).primaryColor,
      primarySwatch: buildMaterialColor(
        Theme.of(context).primaryColor,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Theme.of(context).primaryColor,
        secondary: Theme.of(context).colorScheme.secondary,
        secondaryContainer: Theme.of(context).colorScheme.secondaryContainer,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kWhite, //<-- SEE HERE
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: kWhite,
          fontSize: 12.sp,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: kWhite,
        // titleTextStyle: TextStyle(
        //   color: kWhite,
        //   fontSize: 20.sp,
        // ),
      ),
      scaffoldBackgroundColor: fwhite,
    );
  }

  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => "Search Assets";

  @override
  // TODO: implement searchFieldDecorationTheme
  InputDecorationTheme? get searchFieldDecorationTheme =>
      const InputDecorationTheme(
        hintStyle: TextStyle(color: kWhite),
      );

  @override
  // TODO: implement searchFieldStyle
  TextStyle? get searchFieldStyle => const TextStyle(
        color: kWhite,
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Visibility(
        visible: query.isNotEmpty,
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    // final List<String> filteredItems = items
    //     .where((item) => item.toLowerCase().contains(query.toLowerCase()))
    //     .toList();

    return buildAssetSearchQueryWidget();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildAssetSearchQueryWidget();
  }

// =========================================================================================
// Seach Assests query

  StatefulBuilder buildAssetSearchQueryWidget() {
    return StatefulBuilder(builder: (context, setState) {
      return FutureBuilder(
        future: GraphqlServices().performQuery(
          query: AssetSchema.getAssetList,
          variables: {
            "filter": {
              "clients": userData.domain,
              "offset": 1,
              "pageSize": 20,
              "order": "asc",
              "searchLabel": query,
              "sortField": "displayName"
            }
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return BuildShimmerLoadingWidget(
              height: 50.sp,
            );
          }

          var result = snapshot.data!;

          if (result.hasException) {
            return GraphqlServices().handlingGraphqlExceptions(
              result: result,
              context: context,
              setState: setState,
            );
          }

          AssetsListModel assetsListModel =
              AssetsListModel.fromJson(result.data!);

          List<Assets> assets = assetsListModel.getAssetList?.assets ?? [];

          if (assets.isEmpty) {
            return const Center(child: Text("No data to show"));
          }

          return ListView.separated(
            padding: EdgeInsets.all(5.sp),
            itemCount: assets.length,
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 8.sp,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              Assets asset = assets[index];
              return BuildAssetCard(
                asset: asset,
              );
            },
          );
        },
      );
    });
  }
}
