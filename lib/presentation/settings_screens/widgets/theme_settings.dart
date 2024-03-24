import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/enums.dart';
import '../../../logic/settings_bloc/settings_bloc.dart';
import '../../../logic/theme_bloc/theme_bloc.dart';

class ThemeSettingsSectionWidget extends StatefulWidget {
  final SettingsState settingsState;

  const ThemeSettingsSectionWidget({super.key, required this.settingsState});

  @override
  State<ThemeSettingsSectionWidget> createState() =>
      _ThemeSettingsSectionWidgetState();
}

class _ThemeSettingsSectionWidgetState
    extends State<ThemeSettingsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            // color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(
              children: [
                for (var element in CustomThemes.themesData)
                  GestureDetector(
                    onTap: () {
                      context.read<ThemeBloc>().add(
                            ThemeChangedEvent(
                              themeType: element["themeType"],
                            ),
                          );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
                      padding: EdgeInsets.symmetric(
                          vertical: 1.h, horizontal: 1.5.w),
                      height: 10.h,
                      width: 25.w,
                      decoration: BoxDecoration(
                          color: element["meta_data"]["settingsShowCaseColor"],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(15),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.grey.withOpacity(0.1),
                          //     spreadRadius: 1,
                          //     blurRadius: 3,
                          //     offset: const Offset(0, 3),
                          //   ),
                          // ],
                          border: themeState.selectedThemeType ==
                                  element["themeType"]
                              ? Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                )
                              : null),
                      child: Center(
                        child: Text(
                          element["name"],
                          style: TextStyle(
                            color: element["brightness"] == Brightness.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
