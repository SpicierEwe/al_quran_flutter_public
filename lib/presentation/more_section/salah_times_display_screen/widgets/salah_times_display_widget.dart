import 'dart:async';
import 'dart:ui';

import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/salah_bloc/salah_bloc.dart';
import 'package:al_quran_new/logic/salah_bloc/salah_bloc.dart';
import 'package:al_quran_new/presentation/more_section/salah_times_display_screen/widgets/qibla_compass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import 'package:cupertino_icons/cupertino_icons.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/salah_tImes_utils.dart';
import '../../../../logic/surah_display_bloc/surah_display_bloc.dart';

class SalahTimesDisplayWidget extends StatefulWidget {
  const SalahTimesDisplayWidget({super.key});

  @override
  State<SalahTimesDisplayWidget> createState() =>
      _SalahTimesDisplayWidgetState();
}

class _SalahTimesDisplayWidgetState extends State<SalahTimesDisplayWidget> {


  @override
  Widget build(BuildContext context) {
    List<IconData> salahIcons = [
      Icons.nights_stay_outlined,
      CupertinoIcons.sunrise,
      CupertinoIcons.sun_max_fill,
      CupertinoIcons.sun_min,
      CupertinoIcons.sunset,
      CupertinoIcons.moon_fill,
      Icons.night_shelter,
    ];
    return BlocBuilder<SalahBloc, SalahState>(
      builder: (context, salahState) {
        // Loading
        if (salahState.salahTimes == null) {
          return const Center(
            child: Text('Loading Salah Times...'),
          );
        }
        // Salah Times
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
          ),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                      child: currentSalahCardWidget(
                    context: context,
                    salahState: salahState,
                  )),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: upcomingSalahCardWidget(
                        context: context, salahState: salahState),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Salah Times
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    // horizontal: 4.w,
                    vertical: 2.h,
                  ),
                  decoration: CustomThemes.salahTimesBoxDecoration(
                    context: context,
                  ),
                  child: ListView.builder(
                    // padding: EdgeInsets.symmetric(
                    //   vertical: 1.h,
                    // ),
                    shrinkWrap: true,
                    itemCount: salahState.salahTimes!["times"].length,
                    itemBuilder: (context, index) {
                      String salahName =
                          salahState.salahTimes!["times"].keys.elementAt(index);

                      String time = salahState.salahTimes!["times"].values
                          .elementAt(index);

                      bool isCurrentSalah =
                          salahState.currentSalah["name"] == salahName;

                      String address =
                          "${salahState.addressData!["subLocality"].toString()}, ${salahState.addressData!["locality"].toString()}";
                      return Column(
                        children: [
                          if (index == 0)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 2.h,
                                          bottom: 1.h,
                                          left: 3.w,
                                          right: 3.w,
                                        ),
                                        decoration: const BoxDecoration(
                                            // color: Colors.grey.withOpacity(.19),
                                            ),
                                        child: Row(
                                          children: [
                                            // location
                                            Icon(
                                              Icons.location_on,
                                              size: 20.sp,
                                            ),
                                            // SizedBox(width: 5.w),
                                            SizedBox(width: 3.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    address,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                      salahState.addressData![
                                                          "postalCode"]!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall!
                                                                .color!
                                                                .withOpacity(
                                                                    .55),
                                                          )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: const BoxDecoration(
                                          // color: Colors.grey.withOpacity(.19),
                                          ),
                                      child: Row(
                                        children: [
                                          // location
                                          Icon(
                                            Icons.date_range,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 3.5.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('dd MMM')
                                                    .format(DateTime.now()),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                  DateFormat('EE yy')
                                                      .format(DateTime.now()),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!
                                                            .withOpacity(.55),
                                                      )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey.withOpacity(.25),
                                  thickness: 3,
                                )
                              ],
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 1.5.h,
                              horizontal: 9.w,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentSalah
                                  ? AppVariables.companyColor
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // SALAH ICONS
                                    Icon(
                                      salahIcons[index],
                                      color: isCurrentSalah
                                          ? Colors.white
                                          : Colors.grey.withOpacity(.75),
                                    ),
                                    SizedBox(width: 5.w),
                                    // SALAH NAME
                                    Text(
                                      salahName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: isCurrentSalah
                                                  ? Colors.white
                                                  : null),
                                    ),
                                  ],
                                ),
                                // SALAH TIME
                                Text(
                                  time.toLowerCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: isCurrentSalah
                                              ? Colors.white
                                              : null),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ==================== FUNCTIONS ====================
  Widget currentSalahCardWidget({
    required BuildContext context,
    required SalahState salahState,
  }) {
    const Color textColor = Colors.black87;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.3),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],

        // green plant image
        image: const DecorationImage(
          image: AssetImage('assets/bgs/rasool_allah_names.jpg'),

          fit: BoxFit.cover,
          // colorFilter:
          //     ColorFilter.mode(Colors.black.withOpacity(.3), BlendMode.darken),
        ),
        border: Border.all(
            width: 1.5, color: Theme.of(context).primaryColor.withOpacity(.1)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.1),
            Theme.of(context).primaryColor.withOpacity(1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 1.h,
              ),
              margin: EdgeInsets.only(bottom: .5.h),
              decoration: BoxDecoration(
                color: AppVariables.companyColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.75),
                    blurRadius: 1,
                    spreadRadius: .5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text('current',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                      )),
            ),
            SizedBox(height: .3.h),
            Text(salahState.currentSalah["name"].toString(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 15.sp,
                      color: textColor,
                    )),
            SizedBox(height: 1.h),
            Text('ends in',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black87)),
            Text(salahState.currentSalah["time_remaining"].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    )),
            SizedBox(height: .5.h),
            Wrap(
              children: [
                Text('End time : ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: textColor)),
                Container(
                    padding: EdgeInsets.only(
                      right: 1.w,
                    ),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(.1),
                          Colors.white.withOpacity(.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text('${salahState.currentSalah["end_time"]}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: textColor,
                            ))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget upcomingSalahCardWidget(
      {required BuildContext context, required SalahState salahState}) {
    Color lightColor = Colors.grey.withOpacity(.9);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.19),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('upcoming',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: lightColor,
                    )),
            SizedBox(height: .3.h),
            Text(salahState.upcomingSalah["name"].toString(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: lightColor,
                      fontSize: 15.sp,
                    )),
            SizedBox(height: 1.h),
            Text('starts at',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: lightColor,
                    )),
            Text(salahState.upcomingSalah["start_time"].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: lightColor,
                    )),
            SizedBox(height: .5.h),
            Text('End time : ${salahState.upcomingSalah["end_time"]}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: lightColor,
                    )),
          ],
        ),
      ),
    );
  }
}
