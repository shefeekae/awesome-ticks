import 'package:bloc/bloc.dart';
part 'job_controller_bloc_event.dart';
part 'job_controller_bloc_state.dart';

class JobControllerBlocBloc
    extends Bloc<JobControllerBlocEvent, JobControllerBlocState> {
  JobControllerBlocBloc()
      : super(JobControllerBlocState(jobStatus: "")) {
    on<ChangeJobStatusEvent>((event, emit) {
      // TODO: implement event handler
      emit(
        JobControllerBlocState(
          jobStatus: event.status,
          actualStartTime: state.actualStartTime,
          actualEndTime: state.actualEndTime,
         
        ),
      );
    });

    on<ChangeJobTimeEvent>((event, emit) {
      emit(JobControllerBlocState(
        jobStatus: state.jobStatus,
        actualStartTime: event.actualStartTime,
          actualEndTime: event.actualEndTime,
      
      ));
    });
  }
}
