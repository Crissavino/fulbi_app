import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileLoadingEvent) {
      yield ProfileLoadingState();
    } else if (event is ProfileCompleteEvent) {
      yield ProfileCompleteState();
    } else if (event is ProfileErrorEvent) {
      yield ProfileErrorState();
    }
  }
}
