part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileLoadingEvent extends ProfileEvent {}

class ProfileCompleteEvent extends ProfileEvent {}

class ProfileErrorEvent extends ProfileEvent {}

class ProfileUserLocationLoadedEvent extends ProfileEvent {}

class ProfileUserLocationLoadingEvent extends ProfileEvent {}