part of 'complete_profile_bloc.dart';

@immutable
abstract class CompleteProfileEvent {}

class ProfileCompleteLoadingEvent extends CompleteProfileEvent {}

class ProfileCompletedEvent extends CompleteProfileEvent {}

class ProfileCompleteErrorEvent extends CompleteProfileEvent {}

class ProfileCompleteLoadingUserLocationEvent extends CompleteProfileEvent {}

class ProfileCompleteUserLocationLoadedEvent extends CompleteProfileEvent {}
