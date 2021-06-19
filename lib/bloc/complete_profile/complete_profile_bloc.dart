import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'complete_profile_event.dart';
part 'complete_profile_state.dart';

class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc() : super(CompleteProfileInitial());

  @override
  Stream<CompleteProfileState> mapEventToState(
    CompleteProfileEvent event,
  ) async* {
    if (event is ProfileCompleteLoadingEvent) {
      yield ProfileCompleteLoadingState();
    } else if (event is ProfileCompletedEvent) {
      yield ProfileCompletedState();
    } else if (event is ProfileCompleteErrorEvent) {
      yield ProfileCompleteErrorState();
    } else if (event is ProfileCompleteLoadingUserLocationEvent) {
      yield ProfileCompleteLoadingUserLocationState();
    } else if (event is ProfileCompleteUserLocationLoadedEvent) {
      yield ProfileCompleteUserLocationLoadedState();
    }
  }
}
