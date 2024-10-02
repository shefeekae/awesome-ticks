// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'parts_quantity_bloc.dart';

 class PartsQuantityState {
  List partsList;
  List<PartsModel> localParts;
  bool isRendered;

  PartsQuantityState({
    required this.partsList,
    required this.localParts,
    required this.isRendered,
  });

  @override
  List<Object> get props => [partsList, localParts, isRendered];
}

class PartsQuantityInitial extends PartsQuantityState {
  PartsQuantityInitial({
    required super.partsList,
    required super.localParts,
    required super.isRendered,
  });
}

// class AddState extends PartsQuantityState {
//   // List localParts;

//   AddState({
//     required super.parts,
//     required super.localParts,
//     required super.isRendered,
//   });
// }
