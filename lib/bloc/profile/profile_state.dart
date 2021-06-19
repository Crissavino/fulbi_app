part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileCompleteState extends ProfileState {}

class ProfileErrorState extends ProfileState {}

class ProfileUserLocationLoadedState extends ProfileState {}

class ProfileUserLocationLoadingState extends ProfileState {}