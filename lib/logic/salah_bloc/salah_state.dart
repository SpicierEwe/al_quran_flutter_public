part of 'salah_bloc.dart';

@immutable
class SalahState {
  final Map<String, dynamic>? salahTimes;
  final Map<String, dynamic>? locationCoordinates;
  final Map<String, dynamic>? addressData;

  final Map<String, dynamic> currentSalah;
  final Map<String, dynamic> upcomingSalah;

  final double qiblaDirection;

  final int? lastFetchedTime;

  const SalahState({
    this.salahTimes,
    this.locationCoordinates,
    this.addressData,
    this.currentSalah = const {
      "name": "",
      "time_remaining": "",
      "end_time": "",
    },
    this.upcomingSalah = const {
      "name": "",
      "start_time": "",
      "end_time": "",
    },
    this.qiblaDirection = 0.0,
    this.lastFetchedTime,
  });

  SalahState copyWith({
    Map<String, dynamic>? salahTimes,
    Map<String, dynamic>? locationCoordinates,
    Map<String, dynamic>? addressData,
    Map<String, dynamic>? currentSalah,
    Map<String, dynamic>? upcomingSalah,
    double? qiblaDirection,
    int? lastFetchedTime,
  }) {
    return SalahState(
      salahTimes: salahTimes ?? this.salahTimes,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      addressData: addressData ?? this.addressData,
      currentSalah: currentSalah ?? this.currentSalah,
      upcomingSalah: upcomingSalah ?? this.upcomingSalah,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      lastFetchedTime: lastFetchedTime ?? this.lastFetchedTime,
    );
  }
}
