import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/ui/pages/service%20request/list/widgets/service_request_paged_list.dart';
import 'package:awesometicks/ui/pages/service%20request/search/search_service_requests.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/user_permission.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../../core/models/list_service_request_model.dart';
// ignore: depend_on_referenced_packages
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  static const String id = 'serviceslist';

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  // String title = "";
  final UserDataSingleton userData = UserDataSingleton();

  late bool isManager;

  late PayloadManagementBloc payloadManagementBloc;
  late FilterAppliedBloc filterAppliedBloc;
  late FilterSelectionBloc filterSelectionBloc;

  final PagingController<int, Items> pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);
    filterAppliedBloc = BlocProvider.of(context);
    filterSelectionBloc = BlocProvider.of(context);

    filterAppliedBloc.add(UpdateFilterAppliedCount(count: 0));

    payloadManagementBloc.state.payload = {};
    super.initState();
  }

  @override
  void dispose() {
    filterSelectionBloc.state.filterLabelsMap[FilterType.serviceRequest] = [];
    filterAppliedBloc.state.filterAppliedCount = 0;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(),
      body: PermissionChecking(
        featureGroup: "serviceRequestManagement",
        feature: "serviceRequests",
        permission: "list",
        showNoAccessWidget: true,
        paddingTop: 10.sp,
        child: ServiceRequestPagedList(
          pagingController: pagingController,
        ),
      ),
    );
  }

  // ================================================================================================
  PreferredSizeWidget buildAppbar() {
    // bool visible = !isManager && requestType != "MOVE_OUT";

    bool permission = UserPermissionServices().checkingPermission(
      featureGroup: "serviceRequestManagement",
      feature: "serviceRequests",
      permission: "list",
    );

    return GradientAppBar(
      centerTitle: false,
      title: "Service Requests",
      actions: permission
          ? [
              BlocBuilder<FilterAppliedBloc, FilterAppliedState>(
                builder: (context, state) {
                  var count = state.filterAppliedCount;

                  bool filterApplied = count != 0;

                  return IconButton(
                    onPressed: () async {
                      FilterWidgetHelpers().filterBottomSheet(
                        context: context,
                        filterType: FilterType.serviceRequest,
                        isMobile: true,
                        saveButtonTap: (value) {
                          pagingController.refresh();
                        },
                      );
                    },
                    icon: Builder(builder: (context) {
                      if (!filterApplied) {
                        return const Icon(
                          Icons.filter_alt_off,
                        );
                      }

                      return Badge.count(
                        count: count,
                        child: Icon(
                          filterApplied
                              ? Icons.filter_alt
                              : Icons.filter_alt_off,
                          color: Theme.of(context).colorScheme.secondary,
                          // color: primaryColor,
                        ),
                      );
                    }),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ServiceRequestSearchDelegate(),
                  );
                },
                icon: const Icon(
                  Icons.search,
                ),
              ),
            ]
          : [],
    );
  }
}
