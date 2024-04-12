import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/variables.dart';

part 'theme_event.dart';

part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeChangedEvent>((event, emit) {
      emit(state.copyWith(
        selectedThemeType: event.themeType,
        themeData: themeDataManager(selectedThemeType: event.themeType),
      ));
    });
  }

  // Theme Manager
  /*
  *  loads the theme data according to the theme type
  *
  * */

  ThemeData themeDataManager({required ThemeType selectedThemeType}) {
    for (var element in CustomThemes.themesData) {
      ThemeType themeType = element["themeType"];

      if (themeType == selectedThemeType) {
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            // seed color should be the company color for all the themes
            seedColor: AppVariables.companyColor,
            brightness: element["brightness"],
            background: element["background"],
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: element["appbarColor"],
          ),
        );
      }
    }

    // default white
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomThemes.themesData[0]["seedColor"],
      ),
    );
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      return ThemeState(
        selectedThemeType:
            _convertStringToThemeType(themeName: json["selectedThemeType"]),
        themeData: themeDataManager(
          selectedThemeType:
              _convertStringToThemeType(themeName: json["selectedThemeType"]),
        ),
      );
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    try {
      return {
        /*
         as the ThemeType cant be saved so we strip the end and store it as String
         ex : ThemeType.light -> light
         */
        "selectedThemeType": state.selectedThemeType.toString().split(".")[1],
      };
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  // converts the incoming string to ThemeType in HydratedBloc
  ThemeType _convertStringToThemeType({required String themeName}) {
    for (var element in CustomThemes.themesData) {
      if (element["name"].toString().toLowerCase() ==
          themeName.toString().toLowerCase()) {
        return element["themeType"];
      }
    }
    return ThemeType.light;
  }
}
