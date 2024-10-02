import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'asset_checklist_management_event.dart';
part 'asset_checklist_management_state.dart';

class AssetChecklistManagementBloc
    extends Bloc<AssetChecklistManagementEvent, AssetChecklistManagementState> {
  AssetChecklistManagementBloc()
      : super(AssetChecklistManagementInitial(
            selectedChecklists: [], showAll: false)) {
    on<AssetChecklistManagementEvent>((event, emit) {});

    on<SelectAllAssetChecklistEvent>((event, emit) {
      emit(AssetChecklistManagementState(
          selectedChecklists: event.assetChecklist, showAll: state.showAll));
    });

    on<UnSelectAllAssetChecklistEvent>((event, emit) {
      emit(AssetChecklistManagementState(
          selectedChecklists: [], showAll: state.showAll));
    });

    on<ShowCheckedUncheckedChecklistEvent>((event, emit) {
      emit(AssetChecklistManagementState(
          checkedUncheckedList: event.checkedUncheckedList,
          showAll: state.showAll));
    });

    // on<ShowUncheckedChecklistEvent>((event, emit) {
    //   emit(AssetChecklistManagementState(unCheckedList: event.uncheckedList));
    // });

    on<AddToSelectedChecklistEvent>((event, emit) {
      List<int> selectedChecklist = state.selectedChecklists;

      selectedChecklist.add(event.assetChecklistId);

      emit(AssetChecklistManagementState(
          selectedChecklists: selectedChecklist, showAll: state.showAll));
    });

    on<RemoveFromSelectedChecklistEvent>((event, emit) {
      List<int> selectedChecklist = state.selectedChecklists;

      selectedChecklist.remove(event.assetChecklistId);

      emit(AssetChecklistManagementState(
          selectedChecklists: selectedChecklist, showAll: state.showAll));
    });

    on<ShowAllButtonEvent>((event, emit) {
      bool showAllValue = event.showAll;

      // Emitting a new state with the updated showAll value
      emit(
        AssetChecklistManagementState(
          selectedChecklists: state.selectedChecklists,
          checkedUncheckedList: state.checkedUncheckedList,
          showAll: showAllValue,
          // unCheckedList: state.unCheckedList,
        ),
      );
    });
  }
}
