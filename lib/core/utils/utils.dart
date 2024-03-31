import 'dart:convert';

import 'package:al_quran_new/apis/quran_data_apis.dart';
import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/core/constants/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/language_bloc/language_bloc.dart';
import '../../logic/settings_bloc/settings_bloc.dart';
import '../../logic/surah_names_bloc/surah_names_bloc.dart';
import '../../logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import '../constants/variables.dart';
import 'package:flutter/services.dart';

/// A utility class providing common functions for Quran-related operations.
class Utils {
  /// Retrieves the Quran script font name based on the specified Quran font type.
  ///
  /// This function is used to map user-friendly font type names to the actual
  /// font names used in the Quran application.
  ///
  /// Supported font types:
  /// - "Uthmani": Uthmani script (Hafs style)
  /// - "IndoPak": Indo-Pak script (Nastaleeq style)
  ///
  /// Returns the corresponding font name for the specified Quran font type.
  ///
  /// Example usage:
  /// ```dart
  /// String fontName = Utils.quranScriptName(quranFontName: "Uthmani");
  /// ```
  static String quranScriptName({required String quranScriptName}) {
    switch (quranScriptName.toLowerCase()) {
      case "uthmani":
        return "qpc_uthmani_hafs";
      case "indopak":
        return "text_qpc_nastaleeq";
      // return "text_indopak";

      //     there is no case for tajweed cause they are word images not fonts
    }
    return "";
  }

//   spacer

  static Widget customSpacer({double height = 3.1, double width = 0}) {
    return SizedBox(
      height: height.h,
      width: width.w,
    );
  }

//   displays the tajweed word image

  static Widget displayTajweedWordImages(
      {required int wordIndex,
      required int verseIndex,
      required int surahId,
      required BuildContext context,
      required SettingsState settingsState,
      required int wordsLength}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: .5.w),
      child: ColorFiltered(
        colorFilter: CustomThemes.tajweedColorInverter(context: context),
        child: Image.network(
          isAntiAlias: true,
          semanticLabel: "tajweed_word_image",
          QuranDataApis.getTajweedWordImagesApi(
              surahId: surahId,
              verseNumber: verseIndex + 1,
              wordNumber: wordIndex + 1,
              wordsLength: wordsLength),
          height: settingsState.quranTextFontSize.sp * 2.13,
        ),
      ),
    );
  }

  /* highlight the tajweed word image */

  static Color highlightTajweedWordImage(
      {required String audioPlayerHighlightedWordLocation,
      required BuildContext context,
      bool showRecitationWordHighlight = true,
      required QuranDisplayType quranDisplayType,
      required QuranDisplayType audioPlayerQuranDisplayType,
      required String currentWordLocation,
      required String surahTrackerHighlightedWordLocation}) {
    bool isHighlighted = quranDisplayType == audioPlayerQuranDisplayType &&
        audioPlayerHighlightedWordLocation == currentWordLocation;
    bool isSurahTrackerHighlighted =
        currentWordLocation == surahTrackerHighlightedWordLocation;

    //  highlights color when audio is playing
    if (isHighlighted && showRecitationWordHighlight) {
      return CustomThemes.wordHighlightColorForTajweedImages(
          audioHighlightColor: true, context: context);
    }
    // user touch highlight color
    else if (isSurahTrackerHighlighted) {
      return CustomThemes.wordHighlightColorForTajweedImages(context: context);
    } else {
      return Colors.transparent;
    }
  }

  /*
  * this function highlights the word which the reciter is reciting
  * */
  static Color highlightTextWords(
      {required String audioPlayerHighlightedWordLocation,
      bool showRecitationWordHighlight = true,
      required String surahTrackerHighlightedWordLocation,
      required QuranDisplayType quranDisplayType,
      required QuranDisplayType audioPlayerQuranDisplayType,
      required String currentWordLocation,
      required BuildContext context}) {
    {
      bool isHighlighted = quranDisplayType == audioPlayerQuranDisplayType &&
          audioPlayerHighlightedWordLocation == currentWordLocation;
      bool isSurahTrackerHighlighted =
          currentWordLocation == surahTrackerHighlightedWordLocation;

      if (isHighlighted && showRecitationWordHighlight) {
        return Colors.teal;
        // return Colors.orange;
      } else if (isSurahTrackerHighlighted) {
        return Colors.orange;
        // return Colors.teal;
      }
      return Theme.of(context).textTheme.bodyLarge!.color!;
    }
  }

  static Color highlightVerseInMushafMode(
      {required String audioPlayerHighlightedWordLocation,
      required String surahTrackerHighlightedWordLocation,
      required QuranDisplayType quranDisplayType,
      required QuranDisplayType audioPlayerQuranDisplayType,
      required String currentVerseKey,
      required int pageIndex,
      required BuildContext context}) {
    String audioPlayerHighlightedVerseKey = "";
    String surahTrackerHighlightedVerseKey = "";
    if (quranDisplayType == audioPlayerQuranDisplayType) {
      if (audioPlayerHighlightedWordLocation.isNotEmpty) {
        // extracting verse keys from the highlighted word location
        audioPlayerHighlightedVerseKey =
            ("${audioPlayerHighlightedWordLocation.split(":")[0]}:${audioPlayerHighlightedWordLocation.split(":")[1]}");
      }
      if (surahTrackerHighlightedWordLocation.isNotEmpty) {
        // extracting verse keys from the syrahTracker highlighted word location
        surahTrackerHighlightedVerseKey =
            ("${surahTrackerHighlightedWordLocation.split(":")[0]}:${surahTrackerHighlightedWordLocation.split(":")[1]}");
      }

      // checking

      bool isHighlighted = audioPlayerHighlightedVerseKey == currentVerseKey;
      bool isSurahTrackerHighlighted =
          currentVerseKey == surahTrackerHighlightedVerseKey;

      if (isHighlighted) {
        // if page is even
        if (pageIndex % 2 == 0) {
          return Colors.teal.withOpacity(.13);
        } else {
          return Colors.teal.withOpacity(.13);
        }
      } else if (isSurahTrackerHighlighted) {
        return Colors.amber.withOpacity(.1);
      } else {
        return Colors.transparent;
      }
    }
    return Colors.transparent;
  }

//   spacing settings

  static double wordSpacingSettings({required SettingsState settingsState}) {
    switch (settingsState.selectedQuranScriptType.toLowerCase()) {
      case "indopak": // indopak
        return settingsState.quranTextWordSpacing.w + 2.w;
      case "uthmani": // uthmani
        return settingsState.quranTextWordSpacing.w + 1.5.w;
    }
    return settingsState.quranTextWordSpacing.w;
  }

//   displays the surah names arabic icon

  static Text displaySurahNamesArabicIcon(
      {required int surahIndex,
      double fontSize = 29,
      Color? color,
      bool useNewSurahFont = false,
      required BuildContext context}) {
    // if useNewSurahFont is true, use the new font
    if (useNewSurahFont) {
      return Text(AppVariables.surahNamesIconList[surahIndex].padRight(3, "0"),
          style: TextStyle(
            fontSize: fontSize.sp,
            fontFamily: "surah_arabic_name_font_new",
            fontWeight: FontWeight.normal,
            // todo implement theme color
            color: color ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppVariables.companyColorGold
                    : const Color(0xff223C63)),
          ),
          textAlign: TextAlign.right);
    }
    // if useNewSurahFont is false, use the old font
    return Text(AppVariables.surahNamesIconList[surahIndex],
        style: TextStyle(
          fontSize: fontSize.sp,
          fontFamily: "surah_arabic_name_font",
          fontWeight: FontWeight.normal,
          // todo implement theme color
          color: color ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppVariables.companyColorGold
                  : const Color(0xff223C63)),
        ),
        textAlign: TextAlign.right);
  }

  //   displays surah or Juz number

  static Widget displaySurahOrJuzNumber(
      {required int surahNumber, required BuildContext context}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          image: const AssetImage("assets/components/number_bg.png"),
          height: 9.h,
          width: 9.w,
        ),
        Text(
          (surahNumber).toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  //   displays the surah or juz name

  static Widget surahTopInfo(
      {required BuildContext context, required int surahIndex}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1.5.h,
        horizontal: 2.5.w,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(
            "assets/images/surah_info_bg.jpg",
          ),
          fit: BoxFit.contain,
          repeat: ImageRepeat.repeat,
          colorFilter: Theme.of(context).brightness == Brightness.dark
              ? ColorFilter.mode(Colors.black.withOpacity(.1), BlendMode.dstIn)
              : null,
        ),
      ),
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // REVELATION PLACE
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/small_border.png",
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(
                        context
                                .read<SurahNamesBloc>()
                                .state
                                .surahNamesMetaData![surahIndex]
                            ["revelation_place"],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 8.sp,
                              color: Colors.white,
                            ))),
              ),

              SizedBox(
                width: 1.w,
              ),

              // surah arabic and english name
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    // color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/bigger_border.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                    ),
                    child: Row(
                      children: [
                        // surah arabic name
                        Expanded(
                          flex: 7,
                          child: Utils.displaySurahNamesArabicIcon(
                            context: context,
                            surahIndex: surahIndex,
                            fontSize: 35,
                            color: Colors.white,
                          ),
                        ),
                        // surah info button
                        IconButton(
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              context.push(
                                "/surah_info_display_screen/${surahIndex + 1}",
                              );
                            },
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 1.w,
              ),
              // verse count
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/small_border.png",
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(
                        "${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahIndex]["verses_count"]} ayahs",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 8.sp,
                              color: Colors.white,
                            ))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // static Widget surahTopInfo(
  //     {required BuildContext context, required int surahIndex}) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       vertical: 1.5.h,
  //       horizontal: 2.5.w,
  //     ),
  //     decoration: const BoxDecoration(
  //       border: Border.symmetric(
  //         horizontal: BorderSide(
  //           color: Color(0xffd4af37),
  //         ),
  //       ),
  //       image: DecorationImage(
  //         image: AssetImage(
  //           "assets/images/surah_info_bg.jpg",
  //         ),
  //         fit: BoxFit.fitWidth,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             // REVELATION PLACE
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 20,
  //                 horizontal: 20,
  //               ),
  //               decoration: BoxDecoration(
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(.1),
  //                     spreadRadius: 1,
  //                     blurRadius: 1,
  //                     offset: const Offset(0, 1),
  //                   ),
  //                 ],
  //                 color: Colors.white,
  //                 shape: BoxShape.circle,
  //                 border: const Border.fromBorderSide(
  //                   BorderSide(
  //                     color: Color(0xffd4af37),
  //                   ),
  //                 ),
  //                 // borderRadius: BorderRadius.circular(11),
  //               ),
  //               child: Text(
  //                   context
  //                       .read<SurahNamesBloc>()
  //                       .state
  //                       .surahNamesMetaData![surahIndex]["revelation_place"],
  //                   style: Theme.of(context).textTheme.titleSmall!.copyWith(
  //                         fontSize: 8.sp,
  //                       )),
  //             ),
  //
  //             // surah arabic and english name
  //             Container(
  //               padding: EdgeInsets.symmetric(
  //                 vertical: 1.5.h,
  //                 horizontal: 3.5.w,
  //               ),
  //               decoration: BoxDecoration(
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(.1),
  //                     spreadRadius: 1,
  //                     blurRadius: 1,
  //                     offset: const Offset(0, 1),
  //                   ),
  //                 ],
  //                 color: Colors.white,
  //                 shape: BoxShape.rectangle,
  //                 borderRadius: BorderRadius.circular(5),
  //                 border: const Border.fromBorderSide(
  //                   BorderSide(
  //                     color: Color(0xffd4af37),
  //                   ),
  //                 ),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Utils.displaySurahNamesArabicIcon(
  //                       surahIndex: surahIndex, fontSize: 41),
  //
  //                   // surah translated name
  //                   Text(
  //                       context
  //                           .read<SurahNamesBloc>()
  //                           .state
  //                           .surahNamesMetaData![surahIndex]["name_complex"],
  //                       style: Theme.of(context).textTheme.titleSmall),
  //                 ],
  //               ),
  //             ),
  //
  //             // verse count
  //             Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 15,
  //                   horizontal: 15,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(.1),
  //                       spreadRadius: 1,
  //                       blurRadius: 1,
  //                       offset: const Offset(0, 1),
  //                     ),
  //                   ],
  //                   color: Colors.white,
  //                   shape: BoxShape.circle,
  //                   border: const Border.fromBorderSide(
  //                     BorderSide(
  //                       color: Color(0xffd4af37),
  //                     ),
  //                   ),
  //                   // borderRadius: BorderRadius.circular(11),
  //                 ),
  //                 child: Text(
  //                     "${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahIndex]["verses_count"]}\nverses",
  //                     textAlign: TextAlign.center,
  //                     style: Theme.of(context).textTheme.titleSmall!.copyWith(
  //                           fontSize: 8.sp,
  //                         ))),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

// Display the text word in the selected Quran script ======================
  static Widget displayWordText(
      {required int verseIndex,
      required int wordIndex,
      bool showRecitationWordHighlight = true,
      required SettingsState settingsState,
      required AudioPlayerState audioPlayerState,
      required SurahTrackerState surahTrackerState,
      required QuranDisplayType quranDisplayType,
      required List data,
      required BuildContext context}) {
    return Text(
      data[verseIndex]["words"][wordIndex][Utils.quranScriptName(
              quranScriptName: settingsState.selectedQuranScriptType)]
          .toString(),
      style: TextStyle(
        locale: const Locale("ar"),
        fontFamily: "${settingsState.selectedQuranScriptType}_font",
        fontSize: settingsState.quranTextFontSize.sp,
        height: 1.55,
        color: Utils.highlightTextWords(
          showRecitationWordHighlight: showRecitationWordHighlight,
          audioPlayerHighlightedWordLocation:
              audioPlayerState.highlightWordLocation,
          surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord,
          quranDisplayType: quranDisplayType,
          audioPlayerQuranDisplayType: audioPlayerState.quranDisplayType,
          currentWordLocation: data[verseIndex]["words"][wordIndex]["location"],
          context: context,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  // Display the verse transliteration and translation ======================

  static Widget displayVerseTransliterationAndTranslation(
      {required List surahOrJuzData,
      required verseTranslation,
      required SettingsState settingsState,
      required int verseIndex,
      required BuildContext context}) {
    return Column(
      children: [
        SizedBox(
          height: settingsState.showTransliteration ? 5.h : 3.h,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 2.w,
            right: 1.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // transliteration
              if (settingsState.showTransliteration)
                Wrap(
                  children: [
                    for (int wordIndex = 0;
                        wordIndex <
                            surahOrJuzData[verseIndex]["words"].length - 1;
                        wordIndex++)
                      Text(
                        '${surahOrJuzData[verseIndex]["words"][wordIndex]["transliteration"]["text"]} ',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black26.withOpacity(.7),
                            ),
                      ),
                  ],
                ),
              SizedBox(
                height: 2.5.h,
              ),
              // Display the translation

              // TRANSLATION
              Html(
                data: verseTranslation,
                style: {
                  "body": Style(
                    padding: HtmlPaddings.only(left: 0),
                    margin: Margins.only(left: 0),
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    direction: context
                                .read<LanguageBloc>()
                                .state
                                .selectedLanguage["direction"] ==
                            "ltr"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSize(settingsState.translationFontSize.sp),
                    fontFamily: Utils.translationFonts(context: context),
                    lineHeight: LineHeight.number(
                        Utils.translationFontsLineHeights(context: context)),
                  ),
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  // this function manages the translation font
  /*
  *
  * By default it gives the translation font as a String.
  *
  * if Line height is required then pass isLineHeight as true and it will return the line height value
  * as a double.
  *
  * */
  static dynamic translationFonts({required BuildContext context}) {
    if (context
            .read<LanguageBloc>()
            .state
            .selectedLanguage["name"]
            .toString()
            .toLowerCase() ==
        "urdu") {
      return "urdu_font";
    }

    return null;
  }

  static TextDirection translationTextDirection(
      {required BuildContext context}) {
    if (context
            .read<LanguageBloc>()
            .state
            .selectedLanguage["direction"]
            .toString()
            .toLowerCase() ==
        "ltr") {
      return TextDirection.ltr;
    }

    return TextDirection.rtl;
  }

  static double translationFontsLineHeights({required BuildContext context}) {
    if (context
            .read<LanguageBloc>()
            .state
            .selectedLanguage["name"]
            .toString()
            .toLowerCase() ==
        "urdu") {
      return 1.8;
    }
    return 1.17;
  }
}
