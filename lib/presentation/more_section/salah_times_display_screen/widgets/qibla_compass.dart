import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/salah_bloc/salah_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class QiblaCompassDisplayWidget extends StatefulWidget {
  const QiblaCompassDisplayWidget({super.key});

  @override
  State<QiblaCompassDisplayWidget> createState() =>
      _QiblaCompassDisplayWidgetState();
}

class _QiblaCompassDisplayWidgetState extends State<QiblaCompassDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalahBloc, SalahState>(
      builder: (context, salahState) {
        final double qiblaDirection = salahState.qiblaDirection;

        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error in compass"),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (salahState.qiblaDirection == 0.0) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final double? currentDirection = snapshot.data!.heading;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 1.w,
                        ),
                      ),
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        alignment: Alignment.center,
                        children: [
                          ///this is the compass containing the directions
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppVariables.companyColor,
                                width: 5.w,
                              ),
                              // color: Colors.red,
                            ),
                            child: Transform.rotate(
                              angle:
                                  ((currentDirection)! * (math.pi / 180) * -1),
                              child: Container(
                                child: Image.asset(
                                  'assets/compass_images/compass.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Transform.rotate(
                              angle: ((currentDirection - qiblaDirection) *
                                  (math.pi / 180) *
                                  -1),
                              child: Image.asset(
                                height: 30.h,
                                'assets/compass_images/compass_needle.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                      "QIBLA IS : ${qiblaDirection.toStringAsFixed(2)} ° FROM NORTH",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
