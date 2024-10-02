import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/models/time_sheet_data_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/main.dart';
import 'package:flutter/cupertino.dart';

class TravelTimeServices {
  Future<TimeSheetDataModel?> getTimeSheetData(Map payload) async {
    BuildContext? context = MyApp.navigatorKey.currentContext;

    ActionButtonLoadingBloc? actionButtonLoadingBloc;

    if (context != null) {
      actionButtonLoadingBloc =
          BlocProvider.of<ActionButtonLoadingBloc>(context);

      actionButtonLoadingBloc.add(ActionButtonIsLoadingEvent(isLoading: true));
    }

    var travelTimeData = await GraphqlServices().performQuery(
      query: JobsSchemas.getTimeSheetData,
      variables: {
        "data": payload,
      },
    );

    if (travelTimeData.hasException) {
      actionButtonLoadingBloc!
          .add(ActionButtonIsLoadingEvent(isLoading: false));

      return null;
    }

    if (context != null) {
      actionButtonLoadingBloc!
          .add(ActionButtonIsLoadingEvent(isLoading: false));
    }

    return TimeSheetDataModel.fromJson(travelTimeData.data ?? {});
  }
}
