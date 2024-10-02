import 'package:bloc/bloc.dart';
part 'internet_available_event.dart';
part 'internet_available_state.dart';

class InternetAvailableBloc
    extends Bloc<InternetAvailableEvent, InternetAvailableState> {
  InternetAvailableBloc()
      : super(InternetAvailableInitial(isInternetAvailable: false)) {
    on<ChangeInternetAvailablity>((event, emit) {
      if (event.available == state.isInternetAvailable) {
        return;
      }

      // TODO: implement event handler
      emit(InternetAvailableState(isInternetAvailable: event.available));
    });
  }
}
