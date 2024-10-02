import 'package:awesometicks/ui/shared/functions/get_material_color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../../../core/models/list_service_request_model.dart';
import '../../../../core/schemas/service_request_schemas.dart';
import '../../../../core/services/graphql_services.dart';
import '../../../../utils/themes/colors.dart';
import '../../../shared/widgets/build_custom_tile.dart';
import '../../../shared/widgets/loading_widget.dart';

class ServiceRequestSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kWhite, //<-- SEE HERE
      ),
      primaryColor: Theme.of(context).primaryColor,
      primarySwatch: buildMaterialColor(
        Theme.of(context).primaryColor,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Theme.of(context).primaryColor,
        secondary: Theme.of(context).colorScheme.secondary,
        secondaryContainer: Theme.of(context).colorScheme.secondaryContainer,
      ),
      iconTheme: IconThemeData(
        color: kBlack,
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
  String? get searchFieldLabel => "Search service requests";

  @override
  InputDecorationTheme? get searchFieldDecorationTheme =>
      const InputDecorationTheme(
        hintStyle: TextStyle(color: kWhite),
      );

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        color: kWhite,
      );

  final controller = SuperTooltipController();

  UserDataSingleton userData = UserDataSingleton();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Builder(builder: (context) {
        bool showCloseButton = query.isNotEmpty;

        if (!showCloseButton) {
          return SuperTooltip(
            controller: controller,
            content: const Text(
              "Search Service Request by\n Request Number/Title or\n Requestee Name, Phone Number\n and E-Mail",
            ),
            child: IconButton(
              onPressed: () {
                controller.showTooltip();
              },
              icon: const Icon(
                Icons.info_outline,
              ),
            ),
          );
        }

        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        );
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildServiceRequestsWidget();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildServiceRequestsWidget();
  }

// =========================================================================================
// Seach Assests query

  Widget buildServiceRequestsWidget() {
    Map<String, dynamic> filter = {
      "commonSearch": query,
      "domain": userData.domain,
      "page": -1,
    };

    return StatefulBuilder(builder: (context, setState) {
      return FutureBuilder(
        future: GraphqlServices().performQuery(
          query: ServiceRequestSchemas.listServiceRequest,
          variables: {
            "filter": filter,
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return BuildShimmerLoadingWidget(
              height: 10.h,
            );
          }

          var result = snapshot.data!;

          if (result.hasException) {
            return GraphqlServices().handlingGraphqlExceptions(
              result: result,
              context: context,
              // refetch: refetch,
              setState: setState,
            );
          }

          ListServiceRequestModel listServiceRequestModel =
              ListServiceRequestModel.fromJson(result.data!);

          List<Items> items =
              listServiceRequestModel.listServiceRequests?.items ?? [];

          if (items.isEmpty) {
            return Center(
              child: Lottie.network(
                "https://assets9.lottiefiles.com/packages/lf20_yuisinzc.json",
                repeat: false,
              ),
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              setState.call(() {});
            },
            child: ListView.separated(
              padding: EdgeInsets.all(5.sp),
              itemCount: items.length,
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 5.sp,
                );
              },
              itemBuilder: (context, index) {
                Items item = items[index];

                return BuildCustomListTileWidget(
                  item: item,
                  refresh: () {
                    setState(() {});
                  },
                );
              },
            ),
          );
        },
      );
    });
  }
}
