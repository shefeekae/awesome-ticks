// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_management_bloc.dart';

@immutable
class JobManagementState {
  int completed = 0;
  int assetChecklistCompleted = 0;

  JobManagementState({
    required this.completed,
    required this.assetChecklistCompleted,
  });
}

class JobManagementInitial extends JobManagementState {
  JobManagementInitial(
      {required super.completed, required super.assetChecklistCompleted});
}
