import 'package:bloc/bloc.dart';

part 'action_button_loading_event.dart';
part 'action_button_loading_state.dart';

class ActionButtonLoadingBloc
    extends Bloc<ActionButtonLoadingEvent, ActionButtonLoadingState> {
  ActionButtonLoadingBloc()
      : super(ActionButtonLoadingInitial(isLoading: false)) {
    on<ActionButtonLoadingEvent>((event, emit) {});

    on<ActionButtonIsLoadingEvent>((event, emit) {
      emit(ActionButtonLoadingState(isLoading: event.isLoading));
    });
  }
}
