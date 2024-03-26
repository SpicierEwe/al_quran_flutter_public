import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class MoreDisplayWidget extends StatefulWidget {
  const MoreDisplayWidget({super.key});

  @override
  State<MoreDisplayWidget> createState() => _MoreDisplayWidgetState();
}

class _MoreDisplayWidgetState extends State<MoreDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionsBloc, PermissionsState>(
      builder: (context, permissionsState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // col 1
                Column(
                  children: [
                    // medium
                    mediumContainer(
                        title: 'ALLAH\nNAMES',
                        bgLink: 'assets/bgs/allah_names.jpg',
                        onPressed: () {
                          context.push('/allah_names_display_screen');
                        }),
                    Utils.customSpacer(height: 1.5),
                    // long
                    longContainer(
                        title: "DUA'S",
                        subtitle: "Rabbana Duas in the Qur'an",
                        bgLink: 'assets/bgs/rabbana_duas.jpg',
                        onPressed: () {
                          context.push('/rabbana_duas_display_screen');
                        }),
                  ],
                ),
                SizedBox(
                  width: 3.w,
                ),
                // col 2
                Column(
                  children: [
                    // long
                    longContainer(
                        title: 'Salah Times',
                        bgLink: 'assets/bgs/salah_times.jpg',
                        onPressed: () {
                          context.push('/salah_times_display_screen');
                        }),
                    Utils.customSpacer(height: 1.5),

                    // medium
                    mediumContainer(
                        title: "Rasool Allah names",
                        bgLink: 'assets/bgs/rasool_allah_names.jpg',
                        onPressed: () {
                          context.push('/rasool_allah_names_display_screen');
                        }),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  final double width = 43.w;
  final double borderRadius = 15;

  Widget longContainer(
          {required String title,
          String? subtitle,
          required String bgLink,
          required Function() onPressed}) =>
      Container(
        height: 33.h,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgLink),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
          // color: Colors.purple,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Center(
            child: ListTile(
              title: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              subtitle: subtitle != null
                  ? Padding(
                      padding: EdgeInsets.only(top: .5.h),
                      child: Text(
                        subtitle.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.black87,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );

  Widget mediumContainer(
          {required String title,
          String? subtitle,
          required String bgLink,
          required Function() onPressed}) =>
      Container(
          height: 20.1.h,
          width: width,
          decoration: BoxDecoration(
            // color: Colors.blue,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(bgLink),
              fit: BoxFit.cover,
            ),
          ),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Center(
              child: ListTile(
                title: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                subtitle: subtitle != null
                    ? Padding(
                        padding: EdgeInsets.only(top: .5.h),
                        child: Text(
                          subtitle.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black87,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : null,
              ),
            ),
          ));
}
