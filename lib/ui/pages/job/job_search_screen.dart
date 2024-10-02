import 'package:app_filter_form/app_filter_form.dart';
// import 'package:awesometicks/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:awesometicks/core/blocs/pagination%20controller/pagination_controller_bloc.dart';
import 'package:awesometicks/core/models/assets/assets_list_model.dart';
import 'package:awesometicks/core/schemas/assets_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/ui/pages/home/widgets/job_card.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:sizer/sizer.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';
import '../../../core/models/hive db/list_jobs_model.dart';
import '../../../core/models/listalljobsmodel.dart';
import '../../../core/schemas/jobs_schemas.dart';
import '../../shared/functions/get_material_color.dart';
import '../home/widgets/jobs_list_builder.dart';
import 'job_details.dart';

class JobsSearchDelegate extends SearchDelegate<String> {
  JobsSearchDelegate({
    required this.paginationControllerBloc,
    required this.payloadManagementBloc,
  });

  final PaginationControllerBloc paginationControllerBloc;
  final PayloadManagementBloc payloadManagementBloc;

  UserDataSingleton userData = UserDataSingleton();

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return ThemeData(
      primaryColor: Theme.of(context).primaryColor,
      primarySwatch: buildMaterialColor(
        Theme.of(context).primaryColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kWhite,
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
      ),
    );
  }

  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => "Search Jobs";

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
    return buildJobsSearchWidget();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildJobsSearchWidget();
  }

// =========================================================================================
// Seach Jobs

  Widget buildJobsSearchWidget() {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        if (!state.isInternetAvailable) {
          return fetchingFromLocaldb();
        }

        return StatefulBuilder(builder: (context, setState) {
          return FutureBuilder(
            future: GraphqlServices().performQuery(
              query: JobsSchemas.listAllJobsQuery,
              variables: {
                "queryParam": {
                  "page": 0,
                  "size": 50,
                  "sort": "jobStartTime,desc",
                },
                "data": {
                  "domain": userData.domain,
                  "hasInTeam": true,
                  "status": [],
                  "jobName": query,
                }
              },
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return BuildShimmerLoadingWidget(
                  height: 15.h,
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

              var model = ListAllJobsModel.fromJson(result.data!);

              var jobsList =
                  model.listAllJobsWithPaginationSortSearch?.items ?? [];

              paginationControllerBloc.state.result = jobsList;
              paginationControllerBloc.state.currentPage = 0;
              paginationControllerBloc.state.isCompleted = false;

              // int totalCount = listallJobs
              //         .listAllJobsWithPaginationSortSearch
              //         ?.totalItems ??
              //     0;

              // countBloc.add(ChangeCountEvent(count: totalCount));

              // JobsServices().listAlljobsStoreToLocalDb();
              // JobsServices().storeReasonsToLocalDb();

              // totalItemsValueNotifier.value = totalCount;
              // totalItemsValueNotifier.notifyListeners();

              if (jobsList.isEmpty) {
                return Center(
                  child: Lottie.asset(
                    "assets/lotties/134394-no-transaction.json",
                    repeat: false,
                    width: 70.w,
                    height: 50.h,
                  ),
                );
              }

              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  setState(() {});
                },
                child: JobListviewBuilder(
                  padding: EdgeInsets.all(5.sp),
                  setState: setState,
                  removePagination: true,
                ),
              );
            },
          );
        });
      },
    );
  }

  // =========================================================================================================
  // Fetching from local db.

  Widget fetchingFromLocaldb() {
    return ValueListenableBuilder(
      valueListenable: jobDetailsDbgetBox().listenable(),
      builder: (context, box, child) {
        List<JobDetailsDb> jobDetailsList = box.values.toList();

        List<Items> items = [];

        jobDetailsList.sort(
          (a, b) {
            return b.jobStartTime!.compareTo(a.jobStartTime!);
          },
        );

        for (var element in jobDetailsList) {
          items.add(Items.fromJson(element.toJson()));
        }

        List<Items> searchedList = items.where((element) {
          String jobName = element.jobName ?? "";
          String jobId = element.id == null ? "" : element.id.toString();

          return jobName.toLowerCase().contains(query) ||
              jobId.toLowerCase().contains(query);
        }).toList();

        if (searchedList.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 0.h),
            child: Center(
              child: Lottie.asset(
                "assets/lotties/134394-no-transaction.json",
                repeat: false,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(5.sp),
          itemCount: searchedList.length,
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 5.sp,
            );
          },
          itemBuilder: (context, index) {
            Items item = searchedList[index];

            return BuildJobCardWidget(
              item: item,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  JobDetailsScreen.id,
                  arguments: {
                    "jobId": item.id,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
