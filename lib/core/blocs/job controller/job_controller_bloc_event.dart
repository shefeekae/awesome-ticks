// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_controller_bloc_bloc.dart';

class JobControllerBlocEvent {}

class ChangeJobStatusEvent extends JobControllerBlocEvent {
  String status;

  ChangeJobStatusEvent({
    required this.status,
  });
}

class ChangeJobTimeEvent extends JobControllerBlocEvent {

  int? actualStartTime;
  int? actualEndTime;
  ChangeJobTimeEvent({
  
    this.actualStartTime,
    this.actualEndTime,
  });




  
}
