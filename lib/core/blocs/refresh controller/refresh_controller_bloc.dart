import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'refresh_controller_event.dart';
part 'refresh_controller_state.dart';

class RefreshControllerBloc
    extends Bloc<RefreshControllerEvent, RefreshControllerState> {
  RefreshControllerBloc() : super(RefreshControllerInitial(refreshing: false)) {
    on<ChangeRefreshingValue>((event, emit) {
      // TODO: implement event handler
      emit(RefreshControllerState(refreshing: event.refreshing));
    });
  }
}
