// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'asset_checklist_management_bloc.dart';

class AssetChecklistManagementEvent {}

class SelectAllAssetChecklistEvent extends AssetChecklistManagementEvent {
  List<int> assetChecklist;
  SelectAllAssetChecklistEvent({
    required this.assetChecklist,
  });
}

class AddToSelectedChecklistEvent extends AssetChecklistManagementEvent {
  int assetChecklistId;
  AddToSelectedChecklistEvent({
    required this.assetChecklistId,
  });
}

class RemoveFromSelectedChecklistEvent extends AssetChecklistManagementEvent {
  int assetChecklistId;
  RemoveFromSelectedChecklistEvent({
    required this.assetChecklistId,
  });
}

class UnSelectAllAssetChecklistEvent extends AssetChecklistManagementEvent {}

class ShowCheckedUncheckedChecklistEvent extends AssetChecklistManagementEvent {
  List<int> checkedUncheckedList;
  ShowCheckedUncheckedChecklistEvent({
    required this.checkedUncheckedList,
  });
}

class ShowAllButtonEvent extends AssetChecklistManagementEvent {
  bool showAll;
  ShowAllButtonEvent({
    required this.showAll,
  });
}

// class ShowUncheckedChecklistEvent extends AssetChecklistManagementEvent {
//   List<Checklist> uncheckedList;
//   ShowUncheckedChecklistEvent({
//     required this.uncheckedList,
//   });
// }
