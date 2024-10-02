import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'refreshtoken_controller_event.dart';
part 'refreshtoken_controller_state.dart';

class RefreshtokenControllerBloc
    extends Bloc<RefreshtokenControllerEvent, RefreshtokenControllerState> {
  RefreshtokenControllerBloc()
      : super(RefreshtokenControllerInitial(refreshTokenCalled: false)) {
    on<UpdateRefreshTokenCalledValue>((event, emit) {
      // TODO: implement event handler

      emit(RefreshtokenControllerState(
          refreshTokenCalled: event.refreshTokenCalled));
    });
  }
}
