// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'refresh_controller_bloc.dart';

class RefreshControllerState {
  final bool refreshing;
  RefreshControllerState({
    required this.refreshing,
  });
}

class RefreshControllerInitial extends RefreshControllerState {
  RefreshControllerInitial({required super.refreshing});
}
