import 'dart:async';
import 'dart:ffi';

import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart';
import 'package:al_quran_new/logic/display_type_switcher_bloc/display_type_switcher_bloc.dart';
import 'package:al_quran_new/presentation/widgets/ayah_on_click_menu/ayah_on_click_menu.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/constants/enums.dart';
import '../../../core/utils/utils.dart';
import '../../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../../logic/settings_bloc/settings_bloc.dart';
import '../../../logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import '../../../logic/theme_bloc/theme_bloc.dart';

class SurahMushafModeWidget extends StatefulWidget {
  const SurahMushafModeWidget({
    super.key,
    required this.surahData,
    required this.pages,
    required this.surahId,
    required this.themeBloc,
    required this.player,
  });

  final List surahData;
  final List pages;
  final int surahId;
  final ThemeBloc themeBloc;
  final AudioPlayer player;

  @override
  State<SurahMushafModeWidget> createState() => _SurahMushafModeWidgetState();
}

class _SurahMushafModeWidgetState extends State<SurahMushafModeWidget> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    context.read<AudioPlayerBloc>().add(
        SurahGetMushafModeScrollControllerAudioPLayerEvent(
            scrollController: itemScrollController));

    context
        .read<DisplayTypeSwitcherBloc>()
        .add(GetMushafItemScrollControllerEvent(
          itemScrollController,
        ));

    // This is the listener for the scroll position

    itemPositionsListener.itemPositions.addListener(() async {
      final positions = itemPositionsListener.itemPositions.value;
      final firstIndex = positions.isNotEmpty ? positions.first.index : null;

      if (firstIndex != null) {
        EasyDebounce.debounce(
            'surah_mushaf_mode_debouncer',
            const Duration(milliseconds: 500),
            () => context
                .read<SurahTrackerBloc>()
                .add(SurahDisplayUpdatePageHizbManzilMushafModeEvent(
                  scrollPositionIndex: firstIndex,
                )));

        // Logger().i("firstIndex  : " + firstIndex.toString());
      }
    });
  }

  // scroll to bookmarked  page index containing the bookmarked verse
  int? bookmarkedPageIndex() {
    if (context.read<BookmarkBloc>().state.lastRead["page_index"] != null) {
      /*
      * we are finding the page index cause the page index of surah rendering is different from
      * the actual verse where here the index goes like  0, 1,2.... and actual surah indexes are
      * related to the actual page index of the quran*/
      return widget.pages.indexOf(
          context.read<BookmarkBloc>().state.lastRead["page_index"] + 1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {},
          //   child: const Icon(Icons.arrow_upward),
          // ),
          body: ScrollablePositionedList.builder(
            initialScrollIndex: context
                            .read<AudioPlayerBloc>()
                            .state
                            .quranDisplayType ==
                        QuranDisplayType.surah &&
                    context.read<AudioPlayerBloc>().state.isAudioPlaying &&
                    context.read<AudioPlayerBloc>().state.currentSurahOrJuzId ==
                        widget.surahId.toString() &&
                    context
                            .read<AudioPlayerBloc>()
                            .state
                            .currentAudioPageIndex !=
                        null
                ? context.read<AudioPlayerBloc>().state.currentAudioPageIndex
                    as int
                :

                //     getting surah local  pageIndex
                bookmarkedPageIndex() ?? 0,
            addAutomaticKeepAlives: true,
            itemCount: widget.pages.length,
            itemPositionsListener: itemPositionsListener,
            itemScrollController: itemScrollController,
            itemBuilder: (context, pageIndex) {
              List pageData = widget.surahData
                  .where((element) =>
                      element["page_number"] == widget.pages[pageIndex])
                  .toList();

              // page data gets the data of the page

              // Logger()
              //     .i("pageData  : " + pageData.toString());
              return Container(
                decoration: BoxDecoration(
                  color: pageIndex % 2 == 1
                      ? CustomThemes.verseStripesColor(
                          context: context, isMushaf: true)
                      : null,
                  border: Border.all(
                    width: 3.w,
                    color: const Color(0xffe0c9a6).withOpacity(0.5),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: pageIndex == 0 &&
                          (widget.surahId != 1 || widget.surahId == 9)
                      ? 0
                      : 3.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Column(
                  children: [
                    if (pageIndex == 0 &&
                        widget.surahId != 1 &&
                        widget.surahId != 9)
                      Padding(
                        padding: EdgeInsets.only(top: 2.1.h, bottom: 1.5.h),
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
                    Wrap(
                      alignment: widget.surahId == 1 ||
                              (widget.surahId >= 99 && widget.surahId <= 114)
                          ? WrapAlignment.center
                          : WrapAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      spacing: Utils.wordSpacingSettings(
                          settingsState: settingsState),
                      children: [
                        for (int verseIndex = 0;
                            verseIndex < pageData.length;
                            verseIndex++)
                          for (int wordIndex = 0;
                              wordIndex < pageData[verseIndex]["words"].length;
                              wordIndex++)
                            // TOOL TIP
                            Tooltip(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppVariables.companyColorGold
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                              triggerMode: TooltipTriggerMode.tap,
                              preferBelow: false,
                              showDuration: const Duration(seconds: 10),
                              message: pageData[verseIndex]["words"][wordIndex]
                                  ["translation"]["text"],

                              // when tool tip is triggered it will also highlight the word
                              onTriggered: () async {
                                // Handle the tap for the specific word

                                context
                                    .read<SurahTrackerBloc>()
                                    .add(UpdateHighlightWordEvent(
                                      wordLocation: pageData[verseIndex]
                                          ["words"][wordIndex]["location"],
                                    ));

                                if (!context
                                    .read<AudioPlayerBloc>()
                                    .state
                                    .isAudioPlaying) {
                                  await widget.player.play(UrlSource(
                                      "https://audio.qurancdn.com/${pageData[verseIndex]["words"][wordIndex]["audio_url"]}"));
                                }
                              },

                              child: BlocBuilder<AudioPlayerBloc,
                                  AudioPlayerState>(
                                builder: (context, audioPlayerState) {
                                  return BlocBuilder<SurahTrackerBloc,
                                      SurahTrackerState>(
                                    builder: (context, surahTrackerState) {
                                      // realWordIndex  and realVerseIndex are used to get the real index of the word and verse in the quran
                                      // cause page data have their own array index which doesn't reflect the actual quran index
                                      int realWordIndex = int.parse(
                                              pageData[verseIndex]["words"]
                                                      [wordIndex]["location"]
                                                  .toString()
                                                  .split(":")[2]) -
                                          1;

                                      int actualVerseIndex = int.parse(
                                              pageData[verseIndex]["words"]
                                                      [wordIndex]["location"]
                                                  .toString()
                                                  .split(":")[1]) -
                                          1;
                                      return AyahOnClickButton(
                                        themeState: widget.themeBloc.state,
                                        quranDisplayType:
                                            QuranDisplayType.surah,
                                        surahId: widget.surahId,
                                        verseIndex: actualVerseIndex,
                                        isGestureDetector: true,
                                        child: Container(
                                          // highlight the entire verse containing the word with word itself when a word is selected
                                          color: Utils.highlightVerseInMushafMode(
                                              audioPlayerHighlightedWordLocation:
                                                  audioPlayerState
                                                      .highlightWordLocation,
                                              currentVerseKey:
                                                  pageData[verseIndex]
                                                      ["verse_key"],
                                              pageIndex: pageIndex,
                                              quranDisplayType:
                                                  QuranDisplayType.surah,
                                              audioPlayerQuranDisplayType:
                                                  audioPlayerState
                                                      .quranDisplayType,
                                              surahTrackerHighlightedWordLocation:
                                                  surahTrackerState
                                                      .highlightWord,
                                              context: context),

                                          child: settingsState
                                                      .selectedQuranScriptType ==
                                                  "tajweed"
                                              ? displayTajweedImages(
                                                  audioPlayerState,
                                                  pageData,
                                                  verseIndex,
                                                  wordIndex,
                                                  surahTrackerState,
                                                  realWordIndex,
                                                  actualVerseIndex,
                                                  settingsState)
                                              : displayOtherScriptTextWords(
                                                  pageData,
                                                  verseIndex,
                                                  wordIndex,
                                                  settingsState,
                                                  audioPlayerState,
                                                  surahTrackerState,
                                                  context),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.5.h,
                      ),
                      child: Text(
                        "Page ${pageData[0]["page_number"]}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Text displayOtherScriptTextWords(
      List<dynamic> pageData,
      int verseIndex,
      int wordIndex,
      SettingsState settingsState,
      AudioPlayerState audioPlayerState,
      SurahTrackerState surahTrackerState,
      BuildContext context) {
    return Text(
      pageData[verseIndex]["words"][wordIndex][Utils.quranScriptName(
              quranScriptName: settingsState.selectedQuranScriptType)] +

          // Add a space if the word is  the last word in the verse
          (wordIndex == pageData[verseIndex]["words"].length - 1 ? " " : ""),
      style: TextStyle(
        fontFamily: "${settingsState.selectedQuranScriptType}_font",
        fontSize: settingsState.quranTextFontSize.sp,
        height: 1.55,

        // highlights the word which the reciter is reciting
        color: Utils.highlightTextWords(
          audioPlayerHighlightedWordLocation:
              audioPlayerState.highlightWordLocation,
          surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord,
          quranDisplayType: QuranDisplayType.surah,
          audioPlayerQuranDisplayType: audioPlayerState.quranDisplayType,
          currentWordLocation: pageData[verseIndex]["words"][wordIndex]
              ["location"],
          context: context,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Container displayTajweedImages(
      AudioPlayerState audioPlayerState,
      List<dynamic> pageData,
      int verseIndex,
      int wordIndex,
      SurahTrackerState surahTrackerState,
      int realWordIndex,
      int realVerseIndex,
      SettingsState settingsState) {
    return Container(
      // highlighting the tajweed word image here
      color: Utils.highlightTajweedWordImage(
          context: context,
          quranDisplayType: QuranDisplayType.surah,
          audioPlayerQuranDisplayType: audioPlayerState.quranDisplayType,
          audioPlayerHighlightedWordLocation:
              audioPlayerState.highlightWordLocation,
          currentWordLocation: pageData[verseIndex]["words"][wordIndex]
              ["location"],
          surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord),
      child: Utils.displayTajweedWordImages(
          context: context,
          wordIndex: realWordIndex,
          verseIndex: realVerseIndex,
          surahId: widget.surahId,
          settingsState: settingsState,
          wordsLength: pageData[verseIndex]["words"].length),
    );
  }
}
