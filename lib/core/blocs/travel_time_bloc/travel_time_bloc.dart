import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_event.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_state.dart';
import 'package:awesometicks/core/models/time_sheet_data_model.dart';
import 'package:awesometicks/core/services/travel_time_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// bloc class of TravelTimeBloc

class TravelTimeBloc extends Bloc<TravelTimeEvent, TravelTimeState> {
  TravelTimeBloc() : super(TravelTimeInitialState(timeSheetData: null)) {
    on<TravelTimeInitialEvent>(_onInitial);
    on<TravelTimeButtonChangeEvent>(_onTravelTimeButtonChangeEvent);
  }

  TimeSheetDataModel? timeSheetData;

  /// function invoked on TravelTimeInitialEvent
  /// calls the api getTimeSheetData from TravelTimeServices and assigns to
  /// timeSheetData variable
  Future<void> _onInitial(
    TravelTimeInitialEvent event,
    Emitter<TravelTimeState> emit,
  ) async {
    timeSheetData = await TravelTimeServices().getTimeSheetData(
      event.payload,
    );

    emit(
      TravelTimeState(
          timeSheetData: getLatestItem,
          hasErrorOccurred: timeSheetData == null),
    );
  }

  Future<void> _onTravelTimeButtonChangeEvent(
    TravelTimeButtonChangeEvent event,
    Emitter<TravelTimeState> emit,
  ) async {
    emit(
      TravelTimeState(
        timeSheetData: state.timeSheetData,
      ),
    );
  }

  /// returning the bool the work logs isEmpty or not
  bool get isWorkLogsIsEmpty =>
      timeSheetData?.getTimeSheetData
          ?.where((element) => element.activity == "WORK")
          .isEmpty ??
      true;

  /// gets the first item of the timeSheetDataList
  GetTimeSheetData? get firstInstance =>
      (timeSheetData?.getTimeSheetData ?? []).isEmpty
          ? null
          : timeSheetData?.getTimeSheetData?.first;

  /// getter to check whether timeSheetData is empty or not
  bool get isTimeSheetDataEmpty =>
      timeSheetData?.getTimeSheetData?.isEmpty ?? true;

  /// This variable represents true if the time sheet data have no work
  /// && only trip with both start and endTime Not Null.
  bool get isOnlyTripPresent {
    List<GetTimeSheetData> sheetData = timeSheetData?.getTimeSheetData ?? [];

    return sheetData
            .where(
              (element) => element.activity == "WORK",
            )
            .isEmpty &&
        sheetData
            .where(
              (element) => element.activity == "TRIP",
            )
            .every((element) =>
                element.startTime != null && element.endTime != null);
  }

  /// stop travel button is only visible when the activity is 'TRIP'
  /// and start time is not null and stop time is null
  bool get showTravelStopButton => firstInstance != null
      ? firstInstance?.activity == 'TRIP' &&
          firstInstance?.startTime != null &&
          firstInstance?.endTime == null
      : false;

  GetTimeSheetData? get getLatestItem {
    List<GetTimeSheetData> tripItems = (timeSheetData?.getTimeSheetData ?? []);

    /// Check if getTimeSheetData is null or empty
    if (tripItems.isEmpty) {
      return null;
    }

    /// Sort tripItems based on startTime in descending order
    tripItems.sort((a, b) => (b.startTime ?? 0).compareTo(a.startTime ?? 0));

    /// Return the first item (latest based on startTime) or null if list is empty
    return tripItems.first;
  }
}

// TODO:-

/// initial stage
/// 1 -> Call find job api (gets the job status) and call time sheet api
/// 2 -> if hasTravelTime -> show Start travel, Start button, Cancel button
///                       -> start travel pressed -> stop travel button
///                       ->
///
/// 3 -> if hasTravelTimeIncluded
///                       -> show Start travel, Start button, Cancel button (job should automatically start)
///                       -> start travel pressed -> stop travel button
///                       -> stop travel pressed -> show Start travel, Start button, Cancel button
///                       -> start button pressed (work log started)
///                             -> shows Start travel, Hold, Cancel, Complete buttons
///                             -> Clicks start travel (job should be put to hold)
///                                 -> shows stop travel button
///                                 -> clicks on stop travel button
///                                     -> shows Start travel, Resume, Cancel, Complete
///                                     -> clicks Resume button
///                                     -> shows Start travel, Hold, Cancel, Complete buttons
///
