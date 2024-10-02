import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
part 'job_management_event.dart';
part 'job_management_state.dart';

class JobManagementBloc extends Bloc<JobManagementEvent, JobManagementState> {
  JobManagementBloc()
      : super(JobManagementInitial(completed: 0, assetChecklistCompleted: 0)) {
    on<ChangeCompletedCountEvent>((event, emit) {
      emit(JobManagementState(
          completed: event.completed,
          assetChecklistCompleted: state.assetChecklistCompleted));
    });

    on<ChangeAssetChecklistCompletedCountEvent>((event, emit) {

      emit(JobManagementState(
          completed: state.completed,
          assetChecklistCompleted: event.assetChecklistCompleted));
    });

    on<ResetCompletedCoutEvent>((event, emit) {
      emit(JobManagementState(
        completed: 0,
        assetChecklistCompleted: state.assetChecklistCompleted,
      ));
    });

    on<ResetAssetChecklistCompletedCoutEvent>((event, emit) {
      emit(JobManagementState(
        completed: state.completed,
        assetChecklistCompleted: 0,
      ));
    });
  }
}
