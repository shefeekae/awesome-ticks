// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'refreshtoken_controller_bloc.dart';

class RefreshtokenControllerState {
  bool refreshTokenCalled ;
  RefreshtokenControllerState({
    required this.refreshTokenCalled,
  });
}

class RefreshtokenControllerInitial extends RefreshtokenControllerState {
  RefreshtokenControllerInitial({required super.refreshTokenCalled});
}
