import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'pagination_controller_event.dart';
part 'pagination_controller_state.dart';

class PaginationControllerBloc
    extends Bloc<PaginationControllerEvent, PaginationControllerState> {
  PaginationControllerBloc()
      : super(PaginationControllerInitial(
          currentPage: 0,
          result: [],
          isCompleted: false,
        )) {
    on<UpdateFetchMoreEvent>((event, emit) {
      // TODO: implement event handler
      emit(PaginationControllerState(
        isCompleted: event.isCompleted,
        result: state.result,
        currentPage: event.currentPage,
      ));
    });

    on<UpdateResultDataEvent>((event, emit) {
      emit(PaginationControllerState(
        isCompleted: state.isCompleted,
        result: event.results,
        currentPage: state.currentPage,
      ));
    });
  }
}
