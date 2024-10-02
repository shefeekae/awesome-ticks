import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/spaces_data_model.dart';

part 'spaces_selection_event.dart';
part 'spaces_selection_state.dart';

class SpacesSelectionBloc
    extends Bloc<SpacesSelectionEvent, SpacesSelectionState> {
  SpacesSelectionBloc() : super(SpacesSelectionInitial(spaces: [])) {
    on<AddSpaceValueEvent>((event, emit) {
      state.spaces.add(event.space);

      emit(SpacesSelectionState(spaces: state.spaces));
      // TODO: implement event handler
    });

    on<RemoveSpaceValueEvent>((event, emit) {
      var list = state.spaces;

      int index = list.indexWhere(
        (element) =>
            element.data['data']['identifier'] ==
            event.space.data['data']['identifier'],
      );

      print("index where index: $index");

      if (index != -1) {
        list.removeAt(index);
      }

      print("list length: ${list.length}");

      emit(SpacesSelectionState(spaces: list));
      // TODO: implement event handler
    });

    on<RemoveAllSpacesEvent>((event, emit) => emit(SpacesSelectionState(spaces: []),));
  }
}
