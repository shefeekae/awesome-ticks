// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'count_bloc.dart';

class CountState {
  int count;
  int tabBarIndex;

  CountState({
    required this.count,
    required this.tabBarIndex,
  });
}

class CountInitial extends CountState {
  CountInitial({required super.count,required super.tabBarIndex});
}
