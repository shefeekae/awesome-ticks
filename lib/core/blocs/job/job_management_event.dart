// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_management_bloc.dart';

class JobManagementEvent {}

class ChangeCompletedCountEvent extends JobManagementEvent {
  int completed;
  ChangeCompletedCountEvent({
    required this.completed,
  });
}

class ChangeAssetChecklistCompletedCountEvent extends JobManagementEvent {
  int assetChecklistCompleted;
  ChangeAssetChecklistCompletedCountEvent({
    required this.assetChecklistCompleted,
  });
}

class ResetCompletedCoutEvent extends JobManagementEvent {}

class ResetAssetChecklistCompletedCoutEvent extends JobManagementEvent {}
