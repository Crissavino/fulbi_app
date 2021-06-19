import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoggingInEvent) {
      yield LoggingInState();
    } else if (event is LogInErrorEvent) {
      yield LogInErrorState();
    } else if (event is LoggedInEvent) {
      yield LoggedInState();
    } else if (event is LoggedOutEvent) {
      yield LoggedOutState();
    }
  }
}
