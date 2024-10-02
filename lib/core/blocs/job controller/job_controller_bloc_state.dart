// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_controller_bloc_bloc.dart';

class JobControllerBlocState {
  String jobStatus;


  int? actualStartTime;
  int? actualEndTime;

  JobControllerBlocState({
    required this.jobStatus,
    this.actualStartTime,
    this.actualEndTime,
  });

 
}

class JobControllerBlocInitial extends JobControllerBlocState {
  JobControllerBlocInitial({required super.jobStatus});
 
}
