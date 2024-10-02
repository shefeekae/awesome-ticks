import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/repositories/job/job_details_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'job_details_event.dart';
part 'job_details_state.dart';

class JobDetailsBloc extends Bloc<JobDetailsEvent, JobDetailsState> {
  JobDetailsBloc() : super(JobDetailsInitial()) {
    on<FetchJobDetailDataEvent>((event, emit) async {
      emit(LoadingState());

      var result = await JobDetailsRepository().fetchJobDetails(
        isFirstTimeCall: event.isFirstTimeCall,
        jobId: event.jobId,
      );

      if (result.hasException) {
        emit(ErroHandlingState());
        return;
      }

      var jobDetailsModel = jobDetailsModelFromJson(result.data ?? {});

      emit(SuccessState(jobDetailsModel: jobDetailsModel));

    });
  }
}
