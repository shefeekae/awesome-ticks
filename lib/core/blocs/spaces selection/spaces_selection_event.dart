// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'spaces_selection_bloc.dart';

@immutable
class SpacesSelectionEvent {}

class AddSpaceValueEvent extends SpacesSelectionEvent {
 final SpaceData space;

  AddSpaceValueEvent({
    required this.space,
  });
}


class RemoveSpaceValueEvent extends SpacesSelectionEvent {
 final SpaceData space;
 
  RemoveSpaceValueEvent({
    required this.space,
  });
}


class RemoveAllSpacesEvent extends SpacesSelectionEvent {
}
