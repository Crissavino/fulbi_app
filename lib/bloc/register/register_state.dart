part of 'register_bloc.dart';

@immutable
abstract class RegisterState {}

class RegisterInitial extends RegisterState {
  final String email = '';
  final String fullName = '';
  final String password = '';
  final String confirmPassword = '';
}

class NotValidEmail extends RegisterState {}

class KeepRegistering extends RegisterState {}

class RegisteringState extends RegisterState {}

class RegisteredState extends RegisterState {}

class RegisterErrorState extends RegisterState {}