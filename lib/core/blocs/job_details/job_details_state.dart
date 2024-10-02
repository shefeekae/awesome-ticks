// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_details_bloc.dart';

@immutable
abstract class JobDetailsState {}

class JobDetailsInitial extends JobDetailsState {}

class LoadingState extends JobDetailsState {}

class ErroHandlingState extends JobDetailsState {}

class SuccessState extends JobDetailsState {
  final JobDetailsModel jobDetailsModel;
  SuccessState({
    required this.jobDetailsModel,
  });

                                      
                                      

}
