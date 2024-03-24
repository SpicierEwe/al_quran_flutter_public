part of 'permissions_bloc.dart';

@immutable
abstract class PermissionsEvent {}

class GetLocationPermission extends PermissionsEvent {}
