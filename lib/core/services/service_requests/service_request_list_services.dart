import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/core/schemas/service_request_schemas.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:secure_storage/model/user_data_model.dart';
import '../../models/list_service_request_model.dart';
import '../graphql_services.dart';

class ServiceRequestListServices {
  final UserDataSingleton userData = UserDataSingleton();

  // ===========================================================================
  // Getting the paginated service request list

  void getPaginateList({
    required int pageKey,
    required PagingController<int, Items> pagingController,
    required PayloadManagementBloc payloadManagementBloc,
    Map<String, dynamic> additionalPayload = const {},
  }) async {
    Map<String, dynamic> filter = {
      "commonSearch": "",
      "domain": userData.domain,
      "page": pageKey,
      "size": 10,
      "sort": "requestTime,DESC"
    };

    if (additionalPayload.isNotEmpty) {
      filter.addAll(additionalPayload);
    }

    filter.addAll(payloadManagementBloc.state.payload);

    var result = await GraphqlServices().performQuery(
      query: ServiceRequestSchemas.listServiceRequest,
      variables: {
        "filter": filter,
      },
    );

    if (result.hasException) {
      pagingController.error = result.exception;

      if (kDebugMode) {
        print("SR list exception: ${result.exception}");
      }

      return;
    }

    var model = ListServiceRequestModel.fromJson(result.data ?? {});

    int? totalCount = model.listServiceRequests?.totalItems;

    ListServiceRequests? listServiceRequests = model.listServiceRequests;

    var serviceRequestsList = listServiceRequests?.items ?? [];

    if (totalCount == null) {
      pagingController.appendLastPage(serviceRequestsList);

      return;
    }

    var totalItems = pagingController.itemList ?? [];

    int totalValuesCount = totalItems.length + serviceRequestsList.length;

    if (totalValuesCount == totalCount) {
      pagingController.appendLastPage(serviceRequestsList);
    } else if (serviceRequestsList.isEmpty) {
      pagingController.appendLastPage([]);
    } else {
      pagingController.appendPage(
        serviceRequestsList,
        pageKey + 1,
      );
    }
  }
}
