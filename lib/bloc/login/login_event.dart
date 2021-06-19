part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoggingInEvent extends LoginEvent {}

class LoggedOutEvent extends LoginEvent {}

class LogInErrorEvent extends LoginEvent {}

class LoggedInEvent extends LoginEvent {}