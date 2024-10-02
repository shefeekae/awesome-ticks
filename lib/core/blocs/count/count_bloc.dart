import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'count_event.dart';
part 'count_state.dart';

class CountBloc extends Bloc<CountEvent, CountState> {
  CountBloc() : super(CountInitial(count: 0, tabBarIndex: 0)) {
    on<ChangeCountEvent>((event, emit) {
      // TODO: implement event handler
      emit(CountState(count: event.count, tabBarIndex: state.tabBarIndex));
    });

    on<ChangeTabBarIndexEvent>((event, emit) {
      // TODO: implement event handler
      emit(CountState(count: state.count, tabBarIndex: event.index));
    });
  }
}
