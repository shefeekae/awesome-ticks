// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'count_bloc.dart';

@immutable
abstract class CountEvent {}

class ChangeCountEvent extends CountEvent {
 final int count ;
  
  ChangeCountEvent({
    required this.count,
  });
}


class ChangeTabBarIndexEvent extends CountEvent {
 final int index ;
  
  ChangeTabBarIndexEvent({
    required this.index,
  });
}
