// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'attachments_controller_bloc.dart';

// ignore: must_be_immutable
@immutable
class AttachmentsControllerState {
   List allData;
   List filteredData;
   bool isLoading;

   AttachmentsControllerState({
    required this.filteredData,
    required this.allData,
    required this.isLoading,
  });
}

// ignore: must_be_immutable
class AttachmentsControllerInitial extends AttachmentsControllerState {
  AttachmentsControllerInitial({required super.filteredData, required super.allData, required super.isLoading});
 
}
