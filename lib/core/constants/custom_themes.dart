import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/theme_bloc/theme_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomThemes {
  // custom themes

  static const List<Map<String, dynamic>> themesData = [
    {
      "name": "Light",
      "seedColor": AppVariables.companyColor,
      "brightness": Brightness.light,
      "themeType": ThemeType.light,
      "meta_data": {
        "settingsShowCaseColor": Colors.white,
      }
    },
    {
      "name": "OLED",
      "seedColor": Colors.black,
      "appbarColor": Colors.black,
      "brightness": Brightness.dark,
      "background": Colors.black,
      "themeType": ThemeType.oled,
      "meta_data": {
        "settingsShowCaseColor": Colors.black,
      }
    },
    {
      "name": "Dark",
      "seedColor": Color(0xff1f2125),
      "background": Color(0xff1f2125),
      "appbarColor": Color(0xff252b31),
      "brightness": Brightness.dark,
      "themeType": ThemeType.dark,
      "meta_data": {
        "settingsShowCaseColor": Color(0xff1f2125),
      }
    },
    {
      "name": "Sepia",
      "seedColor": Color(0xfff8ebd5),
      "appbarColor": Color(0xfff8ebd5),
      "brightness": Brightness.light,
      "background": Color(0xfffff7ea),
      "themeType": ThemeType.sepia,
      "meta_data": {
        "settingsShowCaseColor": Color(0xfff8ebd5),
      }
    }
  ];

// supporting variables
/*
  * These variables change conditionally and represent some manual color changes inside
  * according to the THEME
  * */

  static Color verseStripesColor(
      {required BuildContext context, bool isMushaf = false}) {
    final Color defaultColorLight = Colors.amber.shade50;
    final Color defaultColorDark = Colors.grey.shade900;
    final ThemeType themeType = _getThemeType(context: context);

    // if the mushaf is true
    if (isMushaf == true) {
      switch (themeType) {
        case ThemeType.light:
          return defaultColorLight;
        case ThemeType.sepia:
          return defaultColorLight;

        //   dark
        case ThemeType.dark:
          return defaultColorDark;
        case ThemeType.oled:
          return defaultColorDark;
      }
    } else {
      switch (themeType) {
        case ThemeType.light:
          return defaultColorLight;
        case ThemeType.sepia:
          return defaultColorLight;

        //   dark
        case ThemeType.dark:
          return Colors.black38;
        case ThemeType.oled:
          return defaultColorDark;
      }
    }
  }

  /*
  *  Changes the box color of the salah times
  * */
  static BoxDecoration salahTimesBoxDecoration(
      {required BuildContext context}) {
    final ThemeType themeType = _getThemeType(context: context);

    BoxDecoration defaultBoxDecorationLight = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 5,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
    BoxDecoration defaultBoxDecorationDark = BoxDecoration(
      // color: Colors.grey.withOpacity(.19),
      color: Colors.black,
      borderRadius: BorderRadius.circular(10),
      boxShadow: null,
    );

    switch (themeType) {
      case ThemeType.light:
        return defaultBoxDecorationLight;
      case ThemeType.sepia:
        return defaultBoxDecorationLight;
      case ThemeType.dark:
        return BoxDecoration(
            color: Colors.grey.withOpacity(.05),
            borderRadius: BorderRadius.circular(10),
            boxShadow: null);
      case ThemeType.oled:
        return defaultBoxDecorationDark;
    }
  }

  /*
  *
  * There are 2 parameter conditions
  * 1. if the textTheme is given true till will return allahNames font according to the
  *   theme
  *
  * 2. If the textTheme is given false, then it will return the color of the count of the
  * names of Allah and Rasool according to the theme
  *
  * */

  static dynamic allahAndRasoolNamesCountColorAndTextTheme(
      {required BuildContext context, bool allahNamesTextFont = false}) {
    final ThemeType themeType = _getThemeType(context: context);

    const String defaultFontNameLight = "allah_names_font_red";
    const String defaultFontNameDark = "allah_names_font_green";

    final Color defaultFontColorLight = Colors.grey.shade200;
    final Color defaultFontColorDark = Colors.grey.shade900;

    // if textTheme is true, then return the text theme color
    if (allahNamesTextFont == true) {
      switch (themeType) {
        case ThemeType.light:
          return defaultFontNameLight;
        case ThemeType.sepia:
          return defaultFontNameLight;
        case ThemeType.dark:
          return defaultFontNameDark;
        case ThemeType.oled:
          return defaultFontNameDark;
      }
    } else {
      switch (themeType) {
        case ThemeType.light:
          return defaultFontColorLight;
        case ThemeType.sepia:
          return defaultFontColorLight;
        case ThemeType.dark:
          return defaultFontColorDark;
        case ThemeType.oled:
          return defaultFontColorDark;
      }
    }
  }

//   settings verse container Color
  static Color settingsVerseContainerColor({required BuildContext context}) {
    final ThemeType themeType = _getThemeType(context: context);

    const Color defaultColorLight = Color(0xfff8f9fa);
    final Color defaultColorDark = Colors.grey.shade900;

    switch (themeType) {
      case ThemeType.light:
        return defaultColorLight;
      case ThemeType.sepia:
        return Colors.brown.shade50;
      case ThemeType.dark:
        return Colors.black38;
      case ThemeType.oled:
        return defaultColorDark;
    }
  }

//   Tajweed Color inverter
  static ColorFilter tajweedColorInverter({required BuildContext context}) {
    final themeType = context.read<ThemeBloc>().state.selectedThemeType;

    const ColorFilter defaultColorFilterLight = ColorFilter.mode(
      Colors.transparent,
      BlendMode.color,
    );

    const ColorFilter defaultColorFilterDark = ColorFilter.matrix(<double>[
      -1, 0, 0, 0, 255, // Red channel
      0, -1, 0, 0, 255, // Green channel
      0, 0, -1, 0, 255, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel
    ]);

    switch (themeType) {
      case ThemeType.light:
        return defaultColorFilterLight;
      case ThemeType.sepia:
        return defaultColorFilterLight;
      case ThemeType.dark:
        return defaultColorFilterDark;
      case ThemeType.oled:
        return defaultColorFilterDark;
    }
  }

  // this highlights the color of the tajweed images
  static Color wordHighlightColorForTajweedImages(
      {bool audioHighlightColor = false, required BuildContext context}) {
    final defaultAudioHighlightColorLight = Colors.cyanAccent.withOpacity(.35);

    final defaultAudioHighlightColorDark = Colors.teal.withOpacity(.35);

    //
    final defaultTouchHighlightColorLight = Colors.amber.shade100;
    final defaultTouchHighlightColorDark = Colors.blueGrey.withOpacity(.3);

    final ThemeType themeType = _getThemeType(context: context);
    if (audioHighlightColor == true) {
      switch (themeType) {
        case ThemeType.light:
          return defaultAudioHighlightColorLight;
        case ThemeType.sepia:
          return defaultAudioHighlightColorLight;
        case ThemeType.dark:
          return defaultAudioHighlightColorDark;
        case ThemeType.oled:
          return defaultAudioHighlightColorDark;
      }
    } else {
      switch (themeType) {
        case ThemeType.light:
          return defaultTouchHighlightColorLight;
        case ThemeType.sepia:
          return defaultTouchHighlightColorLight;
        case ThemeType.dark:
          return defaultTouchHighlightColorDark;
        case ThemeType.oled:
          return defaultTouchHighlightColorDark;
      }
    }
  }

  // gets the theme type

  static ThemeType _getThemeType({required BuildContext context}) {
    return context.read<ThemeBloc>().state.selectedThemeType;
  }

//   Tajweed Color inverter
}
