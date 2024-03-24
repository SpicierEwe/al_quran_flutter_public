import 'dart:async';

import 'package:al_quran_new/core/utils/salah_tImes_utils.dart';
import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;
import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'salah_event.dart';

part 'salah_state.dart';

class SalahBloc extends HydratedBloc<SalahEvent, SalahState> {
  final PermissionsBloc permissionBloc;

  SalahBloc({required this.permissionBloc}) : super(const SalahState()) {
    on<GetSalahTimesEvent>((event, emit) async {
      //
      // This will only run when the the initial data is either null of a new day has begun
      if ((state.lastFetchedTime == null ||
              SalahTimesUtil.timestampToDateTime(
                          timestamp: state.lastFetchedTime as int)
                      .day !=
                  DateTime.now().day) ||
          event.forceFetch == true) {
        Logger().i("SALAH TIMES event ran");
        Location location = Location();
        LocationData locationData = await location.getLocation();
        List<dynamic> placeMarks = await geo_coding.placemarkFromCoordinates(
            locationData.latitude as double, locationData.longitude as double);

        // print(placeMarks);
        await InternetDataRepository.getSalahTimes(
          latitude: locationData.latitude.toString(),
          longitude: locationData.longitude.toString(),
          onCompleted: (salahTimes) {
            // Logger().i(salahTimes);
            emit(state.copyWith(
              salahTimes: salahTimes,
              locationCoordinates: {
                "latitude": locationData.latitude,
                "longitude": locationData.longitude,
              },
              addressData: {
                "subLocality": placeMarks[0].subLocality,
                "locality": placeMarks[0].locality,
                "postalCode": placeMarks[0].postalCode,
              },
              lastFetchedTime: SalahTimesUtil.dateTimeToTimestamp(),
            ));

            // print(placeMarks);
          },
          onError: (error) {
            Logger().e(error);
          },
        );
      }

      // This will run if the coordinates are not null
      if (state.locationCoordinates != null) {
        add(CalculateCurrentSalahEvent());
        add(GetQiblaDirectionEvent());
      }
    });
    late Timer timer;
    on<CalculateCurrentSalahEvent>((event, emit) async {
      Completer<void> completer = Completer<void>();

      // Start the timer when the calculation is triggered
      void startTimer() async {
        // Schedule the timer to run every second
        timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          // Perform the Salah time calculation
          Map<String, Map<String, dynamic>> calculatedTimes =
              SalahTimesUtil.liveCalculation(salahTimes: state.salahTimes!);

          // Update the state with the new Salah times
          emit(state.copyWith(
            currentSalah: {
              "name": calculatedTimes["current_salah"]!["name"],
              "time_remaining":
                  calculatedTimes["current_salah"]!["time_remaining"],
              "end_time": calculatedTimes["current_salah"]!["end_time"],
            },
            upcomingSalah: {
              "name": calculatedTimes["upcoming_salah"]!["name"],
              "start_time": calculatedTimes["upcoming_salah"]!["start_time"],
              "end_time": calculatedTimes["upcoming_salah"]!["end_time"],
            },
          ));
        });
      }

      startTimer();
      return completer.future;
    });

    on<GetQiblaDirectionEvent>((event, emit) async {
      Completer<void> completer = Completer<void>();
      await InternetDataRepository.getQiblaDirection(
        latitude: state.locationCoordinates!["latitude"].toString(),
        longitude: state.locationCoordinates!["longitude"].toString(),
        onCompleted: (qiblaDirection) {
          // Logger().i("qiblaDirection = $qiblaDirection");

          emit(
            state.copyWith(qiblaDirection: qiblaDirection),
          );
        },
        onError: (error) {
          Logger().e(error);
        },
      );
      return completer.future;
    });

    // cancel the timer
    on<CancelTimerEvent>((event, emit) async {
      timer.cancel();
    });
  }

  @override
  SalahState? fromJson(Map<String, dynamic> json) {
    try {
      return SalahState(
        salahTimes: json["salahTimes"],
        locationCoordinates: json["locationCoordinates"],
        addressData: json["addressData"],
        currentSalah: json["currentSalah"],
        upcomingSalah: json["upcomingSalah"],
        qiblaDirection: json["qiblaDirection"],
        lastFetchedTime: json["lastFetchedTime"],
      );
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SalahState state) {
    try {
      return {
        "salahTimes": state.salahTimes,
        "locationCoordinates": state.locationCoordinates,
        "addressData": state.addressData,
        "currentSalah": state.currentSalah,
        "upcomingSalah": state.upcomingSalah,
        "qiblaDirection": state.qiblaDirection,
        "lastFetchedTime": state.lastFetchedTime,
      };
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }
}
