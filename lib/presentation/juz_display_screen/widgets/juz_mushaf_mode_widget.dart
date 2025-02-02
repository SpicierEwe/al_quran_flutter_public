import 'dart:async';
import 'dart:ffi';

import 'package:al_quran_new/logic/display_type_switcher_bloc/display_type_switcher_bloc.dart';
import 'package:al_quran_new/presentation/widgets/ayah_on_click_menu/ayah_on_click_menu.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:logger/logger.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/constants/custom_themes.dart';
import '../../../core/constants/enums.dart';
import '../../../core/constants/variables.dart';
import '../../../core/utils/utils.dart';
import '../../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../../logic/settings_bloc/settings_bloc.dart';
import '../../../logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import '../../../logic/theme_bloc/theme_bloc.dart';

class JuzMushafModeWidget extends StatefulWidget {
  const JuzMushafModeWidget({
    super.key,
    required this.juzData,
    required this.pages,
    required this.juzId,
    required this.themeBloc,
    required this.player,
  });

  final List juzData;
  final List pages;
  final int juzId;
  final ThemeBloc themeBloc;
  final AudioPlayer player;

  @override
  State<JuzMushafModeWidget> createState() => _JuzMushafModeWidgetState();
}

class _JuzMushafModeWidgetState extends State<JuzMushafModeWidget> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    context.read<AudioPlayerBloc>().add(
        JuzGetMushafModeScrollControllerAudioPLayerEvent(
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
            'juz_mushaf_mode_debouncer',
            const Duration(milliseconds: 500),
            () => context
                .read<SurahTrackerBloc>()
                .add(JuzDisplayUpdatePageHizbManzilMushafModeEvent(
                  scrollPositionIndex: firstIndex,
                )));

        // Logger().i("firstIndex  : " + firstIndex.toString());
      }
    });
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
                        QuranDisplayType.juz &&
                    context.read<AudioPlayerBloc>().state.isAudioPlaying &&
                    context.read<AudioPlayerBloc>().state.currentSurahOrJuzId ==
                        widget.juzId.toString() &&
                    context
                            .read<AudioPlayerBloc>()
                            .state
                            .currentAudioPageIndex !=
                        null
                ? context.read<AudioPlayerBloc>().state.currentAudioPageIndex
                    as int
                : Utils.bookmarkedMushafPageIndex(
                      juzIndex: widget.juzId - 1,
                      isJuz: true,
                      context: context,
                      pages: widget.pages,
                    ) ??
                    0,
            addAutomaticKeepAlives: true,
            itemCount: widget.pages.length,
            itemPositionsListener: itemPositionsListener,
            itemScrollController: itemScrollController,
            itemBuilder: (context, pageIndex) {
              List pageData = widget.juzData
                  .where((element) =>
                      element["page_number"] == widget.pages[pageIndex])
                  .toList();

              // Logger()
              //     .i("pageData  : " + pageData.toString());

              return Container(
                // PAGE border decoration
                decoration: BoxDecoration(
                  color: pageIndex % 2 == 1
                      ? CustomThemes.verseStripesColor(context: context)
                      : null,
                  border: Border.all(
                    width: 3.w,
                    color: const Color(0xffe0c9a6).withOpacity(0.5),
                  ),
                ),
                padding: EdgeInsets.only(
                  top:
                      pageIndex == 0 && (widget.juzId != 1 || widget.juzId == 9)
                          ? 0
                          : 3.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Column(
                  children: [
                    // the padding on the top of the first page of the juz seems off so added some
                    if (pageIndex == 0)
                      Container(
                        padding: EdgeInsets.only(top: 1.5.h),
                      ),
                    // Container(
                    //   padding: EdgeInsets.only(top: .1.h, bottom: 1.5.h),
                    // ),
                    Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          textDirection: TextDirection.rtl,
                          spacing: Utils.wordSpacingSettings(
                              settingsState: settingsState),
                          children: [
                            // Text(pageData.toString()),
                            // Adding a condition to show "new surah" text when verseIndex is 0

                            ..._buildVerses(
                                pageData: pageData,
                                pageIndex: pageIndex,
                                settingsState: settingsState,
                                context: context)
                          ],
                        ),
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

  List<Widget> _buildVerses({
    required List<dynamic> pageData,
    required int pageIndex,
    required SettingsState settingsState,
    required BuildContext context,
  }) {
    List<Widget> verses = [];

    for (int verseIndex = 0; verseIndex < pageData.length; verseIndex++) {
      int surahId =
          int.parse(pageData[verseIndex]["verse_key"].toString().split(":")[0]);
      int actualVerseIndex = int.parse(
              pageData[verseIndex]["verse_key"].toString().split(":")[1]) -
          1;

      // when the actualVerseIndex is 0, it means it's the first verse of the surah
      if (actualVerseIndex == 0) {
        verses.add(
          Container(
              margin: EdgeInsets.only(bottom: 1.5.h, top: 1.5.h),
              child: Column(
                children: [
                  Utils.surahTopInfo(context: context, surahIndex: surahId),
                  // show bismillah
                  if (surahId != 9 || surahId != 1)
                    Padding(
                      padding: EdgeInsets.only(top: 2.1.h, bottom: 1.5.h),
                      child: Text(
                        "﷽",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 30.sp, fontFamily: "bismillah_font"),
                      ),
                    ),
                ],
              )),
        );
      }
      for (int wordIndex = 0;
          wordIndex < pageData[verseIndex]["words"].length;
          wordIndex++) {
        // TOOL TIP

        verses.add(Tooltip(
          decoration: Utils.toolTipDecoration(context: context),
          textStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white),
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          showDuration: const Duration(seconds: 10),

          // when tool tip is triggered it will also highlight the word
          onTriggered: () async {
            // Handle the tap for the specific word

            context.read<SurahTrackerBloc>().add(UpdateHighlightWordEvent(
                  wordLocation: pageData[verseIndex]["words"][wordIndex]
                      ["location"],
                ));

            if (!context.read<AudioPlayerBloc>().state.isAudioPlaying) {
              await widget.player.play(UrlSource(
                  "https://audio.qurancdn.com/${pageData[verseIndex]["words"][wordIndex]["audio_url"]}"));
            }
          },
          message: pageData[verseIndex]["words"][wordIndex]["translation"]
              ["text"],
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, audioPlayerState) {
              return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
                builder: (context, surahTrackerState) {
                  int surahId = int.parse(pageData[verseIndex]["verse_key"]
                      .toString()
                      .split(":")[0]);
                  // realWordIndex  and realVerseIndex are used to get the real index of the word and verse in the quran
                  // cause page data have their own array index which doesn't reflect the actual quran index
                  int realWordIndex = int.parse(pageData[verseIndex]["words"]
                              [wordIndex]["location"]
                          .toString()
                          .split(":")[2]) -
                      1;

                  int realVerseIndex = int.parse(pageData[verseIndex]["words"]
                              [wordIndex]["location"]
                          .toString()
                          .split(":")[1]) -
                      1;
                  return AyahOnClickButton(
                    themeState: widget.themeBloc.state,
                    quranDisplayType: QuranDisplayType.juz,
                    surahId: surahId,
                    verseIndex: realVerseIndex,
                    isGestureDetector: true,
                    child: Container(
                      // "${pageData[verseIndex]["verse_key"]}"),

                      // highlight the entire verse containing the word with word itself when a word is selected
                      color: Utils.highlightVerseInMushafMode(
                          audioPlayerHighlightedWordLocation:
                              audioPlayerState.highlightWordLocation,
                          currentVerseKey: pageData[verseIndex]["verse_key"],
                          pageIndex: pageIndex,
                          quranDisplayType: QuranDisplayType.juz,
                          audioPlayerQuranDisplayType:
                              audioPlayerState.quranDisplayType,
                          surahTrackerHighlightedWordLocation:
                              surahTrackerState.highlightWord,
                          context: context),

                      child: settingsState.selectedQuranScriptType == "tajweed"
                          ? displayTajweedImages(
                              surahId: surahId,
                              audioPlayerState: audioPlayerState,
                              pageData: pageData,
                              verseIndex: verseIndex,
                              wordIndex: wordIndex,
                              surahTrackerState: surahTrackerState,
                              realWordIndex: realWordIndex,
                              realVerseIndex: realVerseIndex,
                              settingsState: settingsState)
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
        ));
      }
    }

    return verses;
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
        color: Utils.highlightTextWords(
          audioPlayerHighlightedWordLocation:
              audioPlayerState.highlightWordLocation,
          surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord,
          quranDisplayType: QuranDisplayType.juz,
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

  Widget displayTajweedImages(
      {required AudioPlayerState audioPlayerState,
      required List<dynamic> pageData,
      required int verseIndex,
      required int surahId,
      required int wordIndex,
      required SurahTrackerState surahTrackerState,
      required int realWordIndex,
      required int realVerseIndex,
      required SettingsState settingsState}) {
    return Container(
      // highlighting the tajweed word image here
      color: Utils.highlightTajweedWordImage(
          context: context,
          quranDisplayType: QuranDisplayType.juz,
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
          surahId: surahId,
          settingsState: settingsState,
          wordsLength: pageData[verseIndex]["words"].length),
    );
  }
}
