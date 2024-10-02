import 'package:awesometicks/core/models/parts_model.dart';
import 'package:bloc/bloc.dart';
part 'parts_quantity_event.dart';
part 'parts_quantity_state.dart';

class PartsQuantityBloc extends Bloc<PartsQuantityEvent, PartsQuantityState> {
  PartsQuantityBloc()
      : super(PartsQuantityInitial(
          localParts: [],
          // parts: [],
          partsList: [],
          isRendered: false,
        )) {
    on<QuantityAddEvent>((event, emit) {
      int index = event.index;

      List<PartsModel> list = state.localParts;

      int quantity = list[index].quantity!;

      list[index].quantity = quantity + 1;

      state.isRendered = true;

      // print("qty: ${state.localParts[index]['quantity']}");
      // print("State parts qty: ${state.parts[index]['name']}");

      emit(
        PartsQuantityState(
          localParts: list,
          // parts: state.parts,
          partsList: state.partsList,
          isRendered: state.isRendered,
        ),
      );
    });

    on<QuantityRemoveEvent>((event, emit) {
      int index = event.index;

      List<PartsModel> list = state.localParts;

      int quantity = list[index].quantity!;

      list[index].quantity = quantity - 1;

      state.isRendered = true;

      emit(PartsQuantityState(
        localParts: list,
        // parts: state.parts,
        partsList: state.partsList,
        isRendered: state.isRendered,
      ));

      // TODO: implement event handler
    });

    on<ResetQuantityEvent>((event, emit) {
      // List parts = state.parts;
      state.isRendered = false;

      emit(PartsQuantityState(
        localParts: state.partsList.map((e) => PartsModel.fromJson(e)).toList(),
        partsList: state.partsList,
        isRendered: state.isRendered,
      ));
    });

    on<PartsRemoveEvent>((event, emit) {
      int index = event.index;

      state.isRendered = true;

      state.localParts.removeAt(index);
      emit(PartsQuantityState(
        partsList: state.partsList,
        localParts: state.localParts,
        isRendered: state.isRendered,
      ));
    });

    on<SaveQuantityEvent>((event, emit) {
        state.isRendered = false;


emit(PartsQuantityState(
        partsList: state.partsList,
        localParts: state.localParts,
        isRendered: state.isRendered,
      ));
    });
  }
}
