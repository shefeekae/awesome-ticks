// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'asset_checklist_management_bloc.dart';

class AssetChecklistManagementState {
  List<int> selectedChecklists;

  List<int> checkedUncheckedList;
  bool showAll;
  // List<Checklist> unCheckedList;

  AssetChecklistManagementState({
    this.selectedChecklists = const [],
    this.checkedUncheckedList = const [],
    required this.showAll,
    // this.unCheckedList = const [],
  });
}

class AssetChecklistManagementInitial extends AssetChecklistManagementState {
  AssetChecklistManagementInitial({required super.selectedChecklists, required super.showAll});
}
