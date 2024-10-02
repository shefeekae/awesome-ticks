import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timeline_update_event.dart';
part 'timeline_update_state.dart';

class TimelineUpdateBloc
    extends Bloc<TimelineUpdateEvent, TimelineUpdateState> {
  TimelineUpdateBloc() : super(TimelineUpdateInitial(timelines: [])) {
    on<TimeLineChangeEvent>((event, emit) {
      state.timelines.add(event.timeline);

      emit(TimelineUpdateState(timelines: state.timelines));
    });
  }
}
