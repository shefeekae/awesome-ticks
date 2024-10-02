part of 'timeline_update_bloc.dart';

@immutable
abstract class TimelineUpdateEvent {}

class TimeLineChangeEvent extends TimelineUpdateEvent {
  final Map<String, dynamic> timeline;

  TimeLineChangeEvent({required this.timeline});
}
