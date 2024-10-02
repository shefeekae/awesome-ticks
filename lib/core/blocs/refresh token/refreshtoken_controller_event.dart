part of 'refreshtoken_controller_bloc.dart';


 class RefreshtokenControllerEvent {
 }

class UpdateRefreshTokenCalledValue extends RefreshtokenControllerEvent{

  bool refreshTokenCalled ;
 
 UpdateRefreshTokenCalledValue({required this.refreshTokenCalled});

}