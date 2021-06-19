import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  
  final UserRepository _userRepository = UserRepository();
  
  RegisterBloc() : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EnterEmail) {
      final bool existEmail = await _userRepository.existEmail(event.email);

      if (existEmail) {
        yield NotValidEmail();
      } else if (event is RegisteringEvent) {
        yield RegisteringState();
      } else if (event is RegisteredEvent) {
        yield RegisteredState();
      } else if (event is RegisterErrorEvent) {
        yield RegisterErrorState();
      } else if (event is KeepRegistering) {
        yield KeepRegistering();
      }
    }
  }
}
