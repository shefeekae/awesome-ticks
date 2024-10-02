import 'package:app_filter_form/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/models/list_service_request_model.dart';
import '../../../../../core/services/service_requests/service_request_list_services.dart';
import '../../../../shared/widgets/build_custom_tile.dart';

class ServiceRequestPagedList extends StatefulWidget {
  final PagingController<int, Items> pagingController;
  final Map<String, dynamic> additionalPayload;

  const ServiceRequestPagedList(
      {required this.pagingController,
      this.additionalPayload = const {},
      super.key});

  @override
  State<ServiceRequestPagedList> createState() =>
      _ServiceRequestPagedListState();
}

class _ServiceRequestPagedListState extends State<ServiceRequestPagedList> {
  late final PagingController<int, Items> pagingController;

  final ServiceRequestListServices serviceRequestListServices =
      ServiceRequestListServices();

  @override
  void initState() {
    pagingController = widget.pagingController;

    PayloadManagementBloc payloadManagementBloc =
        BlocProvider.of<PayloadManagementBloc>(context);

    pagingController.addPageRequestListener(
      (pageKey) {
        serviceRequestListServices.getPaginateList(
          pageKey: pageKey,
          pagingController: pagingController,
          payloadManagementBloc: payloadManagementBloc,
          additionalPayload: widget.additionalPayload,
        );
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView.separated(
      padding: EdgeInsets.all(8.sp),
      pagingController: pagingController,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 7.sp,
        );
      },
      builderDelegate: PagedChildBuilderDelegate<Items>(
        itemBuilder: (context, item, index) {
          return BuildCustomListTileWidget(
            item: item,
            refresh: () {
              pagingController.refresh();
            },
          );
        },
        newPageErrorIndicatorBuilder: (context) {
          return TextButton.icon(
            onPressed: () {
              pagingController.retryLastFailedRequest();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          );
        },
        firstPageProgressIndicatorBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
        newPageProgressIndicatorBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return Padding(
            padding: EdgeInsets.only(top: 15.sp),
            child: Center(
              child: Text(
                "No items found",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
