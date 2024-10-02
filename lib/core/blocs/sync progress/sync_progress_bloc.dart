import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'sync_progress_event.dart';
part 'sync_progress_state.dart';

class SyncProgressBloc extends Bloc<SyncProgressEvent, SyncProgressState> {
  SyncProgressBloc() : super(SyncProgressInitial(total: 0, progress: 0)) {
    on<ChangeSyncProgressEvent>((event, emit) {
      
      // TODO: implement event handler
      emit(
        SyncProgressState(total: state.total, progress: event.progress),
      );
    });

    on<ChangeTotalCountEvent>((event, emit) {
      // TODO: implement event handler
      emit(
        SyncProgressState(total: event.total, progress: state.total),
      );
    });
  }
}
