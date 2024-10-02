// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'pagination_controller_bloc.dart';

class PaginationControllerState {
  bool isCompleted;
  List result;
  int currentPage;
  PaginationControllerState({
    required this.isCompleted,
    required this.result,
    required this.currentPage,
  });


 }

class PaginationControllerInitial extends PaginationControllerState {
  PaginationControllerInitial({required super.isCompleted, required super.result, required super.currentPage});
}
