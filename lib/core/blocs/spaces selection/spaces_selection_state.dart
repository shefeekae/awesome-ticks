// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'spaces_selection_bloc.dart';

class SpacesSelectionState {
   List<SpaceData> spaces;
  SpacesSelectionState({
    required this.spaces,
  });
}

// ignore: must_be_immutable
class SpacesSelectionInitial extends SpacesSelectionState {
  SpacesSelectionInitial({required super.spaces});
}
