import "dart:async";
import "dart:ui";

import "package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart";
import "package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart";
import "package:al_quran_new/logic/display_type_switcher_bloc/display_type_switcher_bloc.dart";
import "package:al_quran_new/logic/settings_bloc/settings_bloc.dart";
import "package:al_quran_new/logic/settings_bloc/settings_bloc.dart";
import "package:audioplayers/audioplayers.dart";

import "package:easy_debounce/easy_debounce.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_html/flutter_html.dart";
import "package:logger/logger.dart";
import "package:scrollable_positioned_list/scrollable_positioned_list.dart";
import "package:sizer/sizer.dart";

import "../../../core/constants/enums.dart";
import "../../../core/constants/variables.dart";
import "../../../core/utils/utils.dart";
import "../../../logic/audio_player_bloc/audio_player_bloc.dart";
import "../../../logic/surah_names_bloc/surah_names_bloc.dart";
import "../../../logic/surah_tracker_bloc/surah_tracker_bloc.dart";
import "../../../logic/theme_bloc/theme_bloc.dart";
import "../../widgets/ayah_on_click_menu/ayah_on_click_menu.dart";
import "../../widgets/ayah_on_click_menu/juz_ayah_on_click_menu.dart";

class JuzVerseByVerseMode extends StatefulWidget {
  const JuzVerseByVerseMode({
    super.key,
    required this.juzData,
    required this.juzId,
    required this.themeBloc,
    required this.player,
    required this.translatedData,
  });

  final List juzData;

  final int juzId;
  final ThemeBloc themeBloc;
  final AudioPlayer player;
  final List translatedData;

  @override
  State<JuzVerseByVerseMode> createState() => _JuzVerseByVerseModeState();
}

class _JuzVerseByVerseModeState extends State<JuzVerseByVerseMode> {
  final ScrollController _scrollController = ScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    // ========================== send the scroll controller to bloc  ==========================
    context.read<AudioPlayerBloc>().add(
        JuzGetVerseByVerseModeScrollControllerAudioPLayerEvent(
            scrollController: itemScrollController));

    context
        .read<DisplayTypeSwitcherBloc>()
        .add(GetVerseByVerseItemScrollControllerEvent(itemScrollController));

    // ========================== Listen to changing item index ==========================

    itemPositionsListener.itemPositions.addListener(() async {
      final positions = itemPositionsListener.itemPositions.value;
      final firstIndex = positions.isNotEmpty ? positions.first.index : null;

      if (firstIndex != null) {
        EasyDebounce.debounce(
            'juz_verse_by_verse_debouncer',
            // <-- An ID for this particular debounce
            const Duration(milliseconds: 200), // <-- The debounce duration
            () {
          context.read<SurahTrackerBloc>().add(
              JuzDisplayUpdatePageHizbManzilVerseByVerseModeEvent(
                  juzId: widget.juzId, scrollPositionIndex: firstIndex));

          // Logger().i("firstIndex  : $firstIndex");
        } // <-- The target method
            );
      }
    });
  }

  // ========================== get the bookmarked verse index ==========================
  bookmarkedVerseIndex() {
    final bookmarkState = context.read<BookmarkBloc>().state;
    if (bookmarkState.lastRead["juz_index"] == widget.juzId - 1) {
      /*
      * the last read verse index gives the actual verse_number -1
      * so in juz we have to find the local index of the last read verse in the juz data
      * so in juz we have to find the index of that surahs actual  verse number in the juz data*/
      int juzVerseLocalIndex = widget.juzData.indexWhere((element) =>
          int.parse(element["verse_key"].toString().split(":")[0]) - 1 ==
              bookmarkState.lastRead["surah_index"] &&
          element["verse_number"] ==
              bookmarkState.lastRead["verse_index"]! + 1);
      Logger().i("juzVerseLocalIndex : $juzVerseLocalIndex");
      return juzVerseLocalIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color unHighlightedIconColor = Colors.grey.withOpacity(.5);
    const Color highlightedIconColor = Color(0xff223C63);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          itemCount: widget.juzData.length,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: context
                          .read<AudioPlayerBloc>()
                          .state
                          .quranDisplayType ==
                      QuranDisplayType.juz &&
                  context.read<AudioPlayerBloc>().state.isAudioPlaying &&
                  context.read<AudioPlayerBloc>().state.currentSurahOrJuzId ==
                      widget.juzId.toString() &&
                  context.read<AudioPlayerBloc>().state.currentAudioIndex !=
                      null
              ? context.read<AudioPlayerBloc>().state.currentAudioIndex as int
              : bookmarkedVerseIndex() ?? 0,
          itemBuilder: (context, verseIndex) {
            final int surahIndex = int.parse(widget.juzData[verseIndex]
                        ["verse_key"]
                    .toString()
                    .split(":")[0]) -
                1;

            final int actualVerseNumber =
                widget.juzData[verseIndex]["verse_number"];

            return BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, bookmarkState) {
                return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, audioPlayerState) {
                    return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
                      builder: (context, surahTrackerState) {
                        return Column(
                          children: [
                            // surah info
                            // ===============================
                            if (actualVerseNumber == 1 || verseIndex == 0)
                              Utils.surahTopInfo(
                                  context: context, surahIndex: surahIndex),
                            JuzAyahOnClickButton(
                              quranDisplayType: QuranDisplayType.juz,
                              verseIndex: verseIndex,
                              surahId: surahIndex + 1,
                              juzId: widget.juzId,
                              actualVerseIndex: actualVerseNumber - 1,
                              child: Column(
                                children: [
                                  // surahIndex ( represents surahs inside the juz )
                                  if (actualVerseNumber == 1 &&
                                      surahIndex + 1 != 1 &&
                                      surahIndex + 1 != 9)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.1.h),
                                      child: Text(
                                        "﷽",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontSize: 30.sp,
                                                fontFamily: "bismillah_font"),
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 1.5.w, right: 0.w, top: 1.h),
                                        child: Column(
                                          children: [
                                            // verse number
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image(
                                                  image: const AssetImage(
                                                      "assets/components/number_bg.png"),
                                                  height: 7.h,
                                                  width: 7.w,
                                                ),
                                                Text(
                                                  (widget.juzData[verseIndex]
                                                          ["verse_number"])
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),

                                            // bookmark icon
                                            if (bookmarkState.lastRead[
                                                        "juz_index"] ==
                                                    widget.juzId - 1 &&
                                                surahIndex ==
                                                    bookmarkState.lastRead[
                                                        "surah_index"] &&
                                                bookmarkState.lastRead[
                                                        "verse_index"] ==
                                                    actualVerseNumber - 1)
                                              const Icon(
                                                Icons.bookmark_added_rounded,
                                              ),

                                            // favourite icon
                                            if (bookmarkState.favourites.any(
                                                (fav) =>
                                                    fav["surahIndex"] ==
                                                        surahIndex &&
                                                    fav["verseIndex"] ==
                                                        actualVerseNumber - 1))
                                              const Icon(
                                                Icons.star_rounded,
                                              ),

                                            // audio icon ( on current playing verse)
                                            if (audioPlayerState
                                                        .quranDisplayType ==
                                                    QuranDisplayType.juz &&
                                                audioPlayerState
                                                        .currentSurahOrJuzId ==
                                                    widget.juzId.toString() &&
                                                audioPlayerState
                                                        .currentAudioIndex ==
                                                    verseIndex)
                                              const Icon(
                                                Icons.volume_up_rounded,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 1.5.w,
                                            right: 4.w,
                                            top: 3.h,
                                            bottom: 3.h,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Display the arabic verse (words)

                                              Wrap(
                                                alignment: WrapAlignment.start,
                                                textDirection:
                                                    TextDirection.rtl,
                                                spacing:
                                                    Utils.wordSpacingSettings(
                                                        settingsState:
                                                            settingsState),
                                                children: [
                                                  for (int wordIndex = 0;
                                                      wordIndex <
                                                          widget
                                                              .juzData[
                                                                  verseIndex]
                                                                  ["words"]
                                                              .length;
                                                      wordIndex++)
                                                    // TOOL TIP
                                                    Tooltip(
                                                      decoration: Utils
                                                          .toolTipDecoration(
                                                              context: context),
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      preferBelow: false,
                                                      showDuration:
                                                          const Duration(
                                                              seconds: 10),

                                                      // when tool tip is triggered it will also highlight the word
                                                      onTriggered: () async {
                                                        // Handle the tap for the specific word

                                                        context
                                                            .read<
                                                                SurahTrackerBloc>()
                                                            .add(UpdateHighlightWordEvent(
                                                                wordLocation: widget.juzData[verseIndex]
                                                                            [
                                                                            "words"]
                                                                        [
                                                                        wordIndex]
                                                                    [
                                                                    "location"]));

                                                        // if audio is  not playing then play the word when clicked
                                                        if (!context
                                                            .read<
                                                                AudioPlayerBloc>()
                                                            .state
                                                            .isAudioPlaying) {
                                                          await widget.player
                                                              .play(UrlSource(
                                                                  "https://audio.qurancdn.com/${widget.juzData[verseIndex]["words"][wordIndex]["audio_url"]}"));
                                                        }
                                                      },
                                                      message: widget.juzData[
                                                                      verseIndex]
                                                                  ["words"]
                                                              [wordIndex][
                                                          "translation"]["text"],
                                                      child: settingsState
                                                                  .selectedQuranScriptType ==
                                                              "tajweed"
                                                          ? Container(
                                                              // highlight
                                                              color: Utils.highlightTajweedWordImage(
                                                                  context:
                                                                      context,
                                                                  quranDisplayType:
                                                                      QuranDisplayType
                                                                          .juz,
                                                                  audioPlayerQuranDisplayType:
                                                                      audioPlayerState
                                                                          .quranDisplayType,
                                                                  audioPlayerHighlightedWordLocation:
                                                                      audioPlayerState
                                                                          .highlightWordLocation,
                                                                  currentWordLocation:
                                                                      widget.juzData[verseIndex]["words"]
                                                                              [
                                                                              wordIndex]
                                                                          [
                                                                          "location"],
                                                                  surahTrackerHighlightedWordLocation:
                                                                      surahTrackerState
                                                                          .highlightWord),

                                                              child: Utils.displayTajweedWordImages(
                                                                  context:
                                                                      context,
                                                                  wordIndex:
                                                                      wordIndex,
                                                                  verseIndex:
                                                                      actualVerseNumber -
                                                                          1,
                                                                  settingsState:
                                                                      settingsState,
                                                                  surahId:
                                                                      surahIndex +
                                                                          1,
                                                                  wordsLength: widget
                                                                      .juzData[
                                                                          verseIndex]
                                                                          [
                                                                          "words"]
                                                                      .length),
                                                            )
                                                          : Utils
                                                              .displayWordText(
                                                              quranDisplayType:
                                                                  QuranDisplayType
                                                                      .juz,
                                                              data: widget
                                                                  .juzData,
                                                              context: context,
                                                              verseIndex:
                                                                  verseIndex,
                                                              wordIndex:
                                                                  wordIndex,
                                                              settingsState:
                                                                  settingsState,
                                                              audioPlayerState:
                                                                  audioPlayerState,
                                                              surahTrackerState:
                                                                  surahTrackerState,
                                                            ),
                                                    ),
                                                ],
                                              ),

                                              // Display the translation and transliteration of the verse
                                              Utils
                                                  .displayVerseTransliterationAndTranslation(
                                                      surahOrJuzData:
                                                          widget.juzData,
                                                      verseTranslation: widget
                                                              .translatedData[
                                                          verseIndex]["text"],
                                                      settingsState:
                                                          settingsState,
                                                      verseIndex: verseIndex,
                                                      context: context),

                                              // sajdah (prostration) display

                                              if (widget.juzData[verseIndex]
                                                      ["sajdah_number"] !=
                                                  null)
                                                Text(
                                                  "-- Sajdah (prostrate) --",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color: Colors.red),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

// Display the text word in the selected Quran script ======================

  Widget displayWordText(
      int verseIndex,
      int wordIndex,
      SettingsState settingsState,
      AudioPlayerState audioPlayerState,
      SurahTrackerState surahTrackerState,
      BuildContext context) {
    return Text(
      widget.juzData[verseIndex]["words"][wordIndex][Utils.quranScriptName(
              quranScriptName: settingsState.selectedQuranScriptType)]
          .toString(),
      style: TextStyle(
        locale: const Locale("ar"),
        fontFamily: "${settingsState.selectedQuranScriptType}_font",
        fontSize: settingsState.quranTextFontSize.sp,
        height: 1.55,
        color: Utils.highlightTextWords(
          audioPlayerHighlightedWordLocation:
              audioPlayerState.highlightWordLocation,
          surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord,
          quranDisplayType: QuranDisplayType.juz,
          audioPlayerQuranDisplayType: audioPlayerState.quranDisplayType,
          currentWordLocation: widget.juzData[verseIndex]["words"][wordIndex]
              ["location"],
          context: context,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}
