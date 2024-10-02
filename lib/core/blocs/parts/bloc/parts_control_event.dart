// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'parts_control_bloc.dart';

@immutable
abstract class PartsControlEvent {}

class ResetPartsEvent extends PartsControlEvent {
  List list;
  ResetPartsEvent({
    required this.list,
  });
}

