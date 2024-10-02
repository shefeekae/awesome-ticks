part of 'pagination_controller_bloc.dart';

@immutable
abstract class PaginationControllerEvent {}


class UpdateFetchMoreEvent extends PaginationControllerEvent {
  final bool isCompleted;
  final int currentPage;

  UpdateFetchMoreEvent({
    this.isCompleted = false,
    this.currentPage = 0,
  });
}

class UpdateResultDataEvent extends PaginationControllerEvent {
  final List results;

  UpdateResultDataEvent({
    required this.results,
  });
}