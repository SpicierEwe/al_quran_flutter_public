part of 'salah_bloc.dart';

@immutable
abstract class SalahEvent {}

class GetSalahTimesEvent extends SalahEvent {
  final bool forceFetch;

  GetSalahTimesEvent({this.forceFetch = false});
}

class CalculateCurrentSalahEvent extends SalahEvent {}

class GetQiblaDirectionEvent extends SalahEvent {
  GetQiblaDirectionEvent();
}

class CancelTimerEvent extends SalahEvent {
  CancelTimerEvent();
}
