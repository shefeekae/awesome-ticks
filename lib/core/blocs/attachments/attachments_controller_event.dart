// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'attachments_controller_bloc.dart';

class AttachmentsControllerEvent {}

class AddAttachmentsListData extends AttachmentsControllerEvent {
   List allData;
   List filteredData;
  AddAttachmentsListData({
    required this.allData,
    required this.filteredData,
  });
}

class UpdateFilteredData extends AttachmentsControllerEvent {
  List filteredData;
  UpdateFilteredData({
    required this.filteredData,
  });
}

class AddNewAttachmentData extends AttachmentsControllerEvent {
  Map data;

  AddNewAttachmentData({
    required this.data,
  });
}

class ChangeLoadingDataEvent extends AttachmentsControllerEvent {
  final bool isLoading;
  ChangeLoadingDataEvent({
    required this.isLoading,
  });
}
