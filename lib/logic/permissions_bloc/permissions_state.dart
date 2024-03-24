part of 'permissions_bloc.dart';

@immutable
class PermissionsState {
  // =========== location permission ===========
  final bool isLocationPermissionGranted;
  final bool isLocationServiceEnabled;

  const PermissionsState({
    // =========== location permission ===========
    this.isLocationPermissionGranted = false,
    this.isLocationServiceEnabled = false,
  });

  PermissionsState copyWith({
    // =========== location permission ===========
    bool? isLocationPermissionGranted,
    bool? isLocationServiceEnabled,
  }) {
    return PermissionsState(
      // =========== location permission ===========
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }
}
