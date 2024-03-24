import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:location/location.dart';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'permissions_event.dart';

part 'permissions_state.dart';

class PermissionsBloc extends HydratedBloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc() : super(const PermissionsState()) {
    //
    on<PermissionsEvent>((event, emit) async {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          emit(state.copyWith(isLocationServiceEnabled: false));
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          emit(state.copyWith(isLocationPermissionGranted: false));
          if (permissionGranted == PermissionStatus.deniedForever) {
            Logger().i('Permission denied forever');
            emit(state.copyWith(isLocationPermissionGranted: false));
            await AppSettings.openAppSettings();
            return;
          }
        }
      }

      locationData = await location.getLocation();
      emit(state.copyWith(
        isLocationPermissionGranted: true,
        isLocationServiceEnabled: true,
      ));
    });
  }

  @override
  PermissionsState? fromJson(Map<String, dynamic> json) {
    try {
      return PermissionsState(
        isLocationPermissionGranted: json['isLocationPermissionGranted'],
        isLocationServiceEnabled: json['isLocationServiceEnabled'],
      );
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PermissionsState state) {
    try {
      return {
        'isLocationPermissionGranted': state.isLocationPermissionGranted,
        'isLocationServiceEnabled': state.isLocationServiceEnabled,
      };
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }
}
