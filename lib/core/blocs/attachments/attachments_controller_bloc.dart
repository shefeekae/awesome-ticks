
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'attachments_controller_event.dart';
part 'attachments_controller_state.dart';

class AttachmentsControllerBloc
    extends Bloc<AttachmentsControllerEvent, AttachmentsControllerState> {
  AttachmentsControllerBloc()
      : super(AttachmentsControllerInitial(allData: const [], filteredData: const [], isLoading: false)) {
    on<AddAttachmentsListData>((event, emit) {
      emit(AttachmentsControllerState(
        allData: event.allData,
        filteredData: event.filteredData,
        isLoading: false,
      ));
    });

    on<AddNewAttachmentData>((event, emit) {
      state.filteredData.add(event.data);
            state.allData.add(event.data);


      emit(AttachmentsControllerState(
        filteredData: state.filteredData,
        allData: state.filteredData,
        isLoading: state.isLoading,
      ));
    });

     on<UpdateFilteredData>((event, emit) {
      emit(
        AttachmentsControllerState(
          allData: state.allData,
          filteredData: event.filteredData,
          isLoading: state.isLoading,
        ),
      );
    });

    on<ChangeLoadingDataEvent>((event, emit) {
      emit(
        AttachmentsControllerState(
          allData: state.allData,
          filteredData: state.filteredData,
          isLoading: event.isLoading,
        ),
      );
      // TODO: implement event handler
    });
  }
}
