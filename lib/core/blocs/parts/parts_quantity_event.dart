// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'parts_quantity_bloc.dart';

abstract class PartsQuantityEvent {}

class QuantityAddEvent extends PartsQuantityEvent {
  final int index;

  QuantityAddEvent({
    required this.index,
  });
}

class QuantityRemoveEvent extends PartsQuantityEvent {
  final int index;
  QuantityRemoveEvent({
    required this.index,
  });
}

class ResetQuantityEvent extends PartsQuantityEvent {
  ResetQuantityEvent();
}

class PartsRemoveEvent extends PartsQuantityEvent {
  int index;
  PartsRemoveEvent(
    this.index,
  );
}

class SaveQuantityEvent extends PartsQuantityEvent {
  SaveQuantityEvent(
  );
}
