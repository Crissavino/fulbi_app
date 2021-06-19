part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {
  final String email = '';
  final String password = '';
}

class LoggingInState extends LoginState {}

class LogInErrorState extends LoginState {}

class LoggedInState extends LoginState {
  final String email = '';
  final String password = '';
}

class LoggedOutState extends LoginState {
  final String email = '';
  final String password = '';
}
