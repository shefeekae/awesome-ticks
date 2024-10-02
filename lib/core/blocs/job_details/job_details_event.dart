// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'job_details_bloc.dart';

@immutable
class JobDetailsEvent {}

class FetchJobDetailDataEvent extends JobDetailsEvent {
  final int jobId;
  final bool isFirstTimeCall;

  FetchJobDetailDataEvent({
    required this.jobId,
    this.isFirstTimeCall = false,
  });
}
