part of 'internet_available_bloc.dart';

class InternetAvailableEvent {}

class ChangeInternetAvailablity extends InternetAvailableEvent {
  bool available;

  ChangeInternetAvailablity({required this.available});
}
