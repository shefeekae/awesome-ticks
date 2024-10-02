import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }

  @override
  Meeting? convertAppointmentToObject(
      Object? customData, Appointment appointment) {
    // TODO: implement convertAppointmentToObject

    Meeting meeting = customData as Meeting;

    return Meeting(
      eventName: meeting.eventName,
      from: meeting.from,
      to: meeting.to,
      background: meeting.background,
      id: meeting.id,
      criticality: meeting.criticality,
      status: meeting.status,
      // location: meeting.location,
    );
  }

  // @override
  // List<Object>? getResourceIds(int index) {
  //   // TODO: implement getResourceIds

  //   return _getMeetingData(index).id;
  // }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting({
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.id,
    required this.criticality,
    required this.status,
    // required this.location,
    this.isAllDay = false,
  });

  int id;

  String criticality;

  String status;

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  // String? location;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}
