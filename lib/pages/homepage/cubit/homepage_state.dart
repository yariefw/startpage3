part of 'homepage_cubit.dart';

abstract class HomepageState {}

class HomepageInitial extends HomepageState {}

class HomepageLoading extends HomepageState {}

class HomepageLoaded extends HomepageState {
  final int? workStartHour;
  final int? workStartMinute;
  final int? workFinishHour;
  final int? workFinishMinute;

  HomepageLoaded({
    this.workStartHour,
    this.workStartMinute,
    this.workFinishHour,
    this.workFinishMinute,
  });
}

class HomepageError extends HomepageState {
  final String message;
  HomepageError({required this.message});
}
