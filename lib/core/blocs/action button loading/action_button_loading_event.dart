// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'action_button_loading_bloc.dart';

class ActionButtonLoadingEvent {}

class ActionButtonIsLoadingEvent extends ActionButtonLoadingEvent{
  bool isLoading;
  
  
  ActionButtonIsLoadingEvent({
    required this.isLoading,
  });
  
  
}
