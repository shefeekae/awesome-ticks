import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'parts_control_event.dart';
part 'parts_control_state.dart';

class PartsControlBloc extends Bloc<PartsControlEvent, PartsControlState> {
  PartsControlBloc() : super(PartsControlInitial(parts: [])) {
    on<ResetPartsEvent>((event, emit) {
      // TODO: implement event handler
      
    });
  }
}
