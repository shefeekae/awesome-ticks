/// event class of TravelTimeBloc

abstract class TravelTimeEvent {}

class TravelTimeInitialEvent extends TravelTimeEvent {
  final Map<String, dynamic> payload;

  TravelTimeInitialEvent({required this.payload});
}

class TravelTimeButtonChangeEvent extends TravelTimeEvent {
  final bool value;

  TravelTimeButtonChangeEvent({required this.value});
}
