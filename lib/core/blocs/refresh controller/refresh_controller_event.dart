// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'refresh_controller_bloc.dart';

@immutable
abstract class RefreshControllerEvent {}

class ChangeRefreshingValue extends RefreshControllerEvent {
  final bool refreshing;
  ChangeRefreshingValue({
    required this.refreshing,
  });
}
