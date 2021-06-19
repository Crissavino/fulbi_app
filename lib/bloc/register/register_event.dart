part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent {}

class EnterEmail extends RegisterEvent {
  final String email;

  EnterEmail(this.email);

}

class RegisteringEvent extends RegisterEvent {}

class RegisteredEvent extends RegisterEvent {}

class RegisterErrorEvent extends RegisterEvent {}