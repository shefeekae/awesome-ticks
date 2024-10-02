import 'package:app_filter_form/core/blocs/filter/filter%20applied/filter_applied_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:app_filter_form/core/services/form_filter_enum.dart';
import 'package:awesometicks/core/models/list_service_request_model.dart';
import 'package:awesometicks/core/schemas/service_request_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/ui/pages/assets/details/widgets/asset_service_request_form.dart';
import 'package:awesometicks/ui/shared/widgets/build_custom_tile.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AssetServiceRequestWidget extends StatefulWidget {
  const AssetServiceRequestWidget(
      {super.key,
      required this.domain,
      required this.resourceId,
      required this.assetData});

  final String domain;
  final String resourceId;
  final Map<String, dynamic> assetData;

  @override
  State<AssetServiceRequestWidget> createState() =>
      _AssetServiceRequestWidgetState();
}

class _AssetServiceRequestWidgetState extends State<AssetServiceRequestWidget> {
  late PayloadManagementBloc payloadManagementBloc;
  late FilterAppliedBloc filterAppliedBloc;
  late FilterSelectionBloc filterSelectionBloc;
  late final PagingController<int, Items> pagingController;

  @override
  void initState() {
    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);
    filterAppliedBloc = BlocProvider.of<FilterAppliedBloc>(context);

    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);
    payloadManagementBloc.state.payload = {};
    filterAppliedBloc.add(UpdateFilterAppliedCount(count: 0));

    super.initState();
  }

  @override
  void dispose() {
    filterSelectionBloc.state.filterLabelsMap[FilterType.serviceRequest] = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> assetPayload = {
      'resource': [
        {
          "domain": widget.domain,
          "resourceId": widget.resourceId,
        }
      ]
    };

    //  payloadManagementBloc.state.payload['resource'] = [
    //       {
    //         "domain": widget.domain,
    //         "resourceId": widget.resourceId,
    //       }
    //     ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AssetServiceRequestFormWidget(
              assetData: widget.assetData,
            ),
          ));
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          pagingController.refresh();
        },
        child: PermissionChecking(
          featureGroup: "serviceRequestManagement",
          feature: "serviceRequests",
          permission: "list",
          showNoAccessWidget: true,
          paddingTop: 10.sp,
          child: StatefulBuilder(builder: (context, setState) {
            return BlocBuilder<PayloadManagementBloc, PayloadManagementState>(
              builder: (context, state) {
                Map<String, dynamic> filter = state.payload;

                filter.addAll(assetPayload);

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
                        listServiceRequestModel.listServiceRequests?.items ??
                            [];

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
                        setState(
                          () {},
                        );
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
                            refresh: () {},
                            item: item,
                            // onTap: () async {
                            //   await Navigator.of(context)
                            //       .pushNamed(ServiceDetailsScreen.id, arguments: {
                            //     "requestNumber": item.requestNumber,
                            //     "jobId": item.jobId != null
                            //         ? int.parse(
                            //             item.jobId!,
                            //           )
                            //         : null,
                            //   });
                            //   setState(
                            //     () {},
                            //   );
                            // },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
