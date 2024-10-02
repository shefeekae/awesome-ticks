import 'package:awesometicks/core/models/time_sheet_data_model.dart';

/// state class of TravelTimeBloc

class TravelTimeState {
  /// if showStartButton is true => Shows Start Travel button
  /// if showStartButton is false => Shows Stop Travel button
  /// if showStartButton is null => Shows nothing

  final GetTimeSheetData? timeSheetData;
  final bool hasErrorOccurred;

  TravelTimeState({required this.timeSheetData, this.hasErrorOccurred = false});
}

class TravelTimeInitialState extends TravelTimeState {
  TravelTimeInitialState({
    required super.timeSheetData,
  });
}
