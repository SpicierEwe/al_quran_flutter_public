import "package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart";
import "package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart";
import "package:al_quran_new/logic/display_type_switcher_bloc/display_type_switcher_bloc.dart";
import "package:al_quran_new/logic/settings_bloc/settings_bloc.dart";
import "package:al_quran_new/logic/settings_bloc/settings_bloc.dart";
import "package:audioplayers/audioplayers.dart";
import "package:easy_debounce/easy_debounce.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_html/flutter_html.dart";
import "package:logger/logger.dart";
import "package:scrollable_positioned_list/scrollable_positioned_list.dart";
import "package:sizer/sizer.dart";

import "../../../core/constants/enums.dart";
import "../../../core/constants/variables.dart";
import "../../../core/utils/utils.dart";
import "../../../logic/audio_player_bloc/audio_player_bloc.dart";
import "../../../logic/surah_tracker_bloc/surah_tracker_bloc.dart";
import "../../../logic/theme_bloc/theme_bloc.dart";
import "../../widgets/ayah_on_click_menu/ayah_on_click_menu.dart";

class SurahVerseByVerseMode extends StatefulWidget {
  const SurahVerseByVerseMode({
    super.key,
    required this.surahData,
    required this.surahId,
    required this.themeBloc,
    required this.player,
    required this.translatedData,
  });

  final List surahData;

  final int surahId;
  final ThemeBloc themeBloc;
  final AudioPlayer player;
  final List translatedData;

  @override
  State<SurahVerseByVerseMode> createState() => _SurahVerseByVerseModeState();
}

class _SurahVerseByVerseModeState extends State<SurahVerseByVerseMode> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    // ========================== send the scroll controller to bloc  ==========================

    // Use WidgetsBinding to add a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // scrolls to the favourite verse
      context.read<BookmarkBloc>().add(ScrollToFavouriteVerseEvent(
          itemScrollController: itemScrollController));
    });

    // audio player bloc
    context.read<AudioPlayerBloc>().add(
        SurahGetVerseByVerseModeScrollControllerAudioPLayerEvent(
            scrollController: itemScrollController));

    // display type switcher bloc
    context
        .read<DisplayTypeSwitcherBloc>()
        .add(GetVerseByVerseItemScrollControllerEvent(itemScrollController));

    // ========================== Listen to changing item index ==========================

    itemPositionsListener.itemPositions.addListener(() async {
      final positions = itemPositionsListener.itemPositions.value;
      final firstIndex = positions.isNotEmpty ? positions.first.index : null;

      if (firstIndex != null) {
        EasyDebounce.debounce(
            'surah_verse_by_verse_debouncer',
            // <-- An ID for this particular debounce
            const Duration(milliseconds: 200), // <-- The debounce duration
            () {
          context.read<SurahTrackerBloc>().add(
              SurahDisplayUpdatePageHizbManzilVerseByVerseModeEvent(
                  chapterId: widget.surahId, scrollPositionIndex: firstIndex));

          // Logger().i("firstIndex  : $firstIndex");
        } // <-- The target method
            );
      }
    });
  }

  // ========================== get the bookmarked verse index ==========================
  bookmarkedVerseIndex() {
    final bookmarkState = context.read<BookmarkBloc>().state;
    if (bookmarkState.lastRead["surah_index"] == widget.surahId - 1) {
      return bookmarkState.lastRead["verse_index"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          itemCount: widget.surahData.length,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: context
                          .read<AudioPlayerBloc>()
                          .state
                          .quranDisplayType ==
                      QuranDisplayType.surah &&
                  context.read<AudioPlayerBloc>().state.isAudioPlaying &&
                  context.read<AudioPlayerBloc>().state.currentSurahOrJuzId ==
                      widget.surahId.toString() &&
                  context.read<AudioPlayerBloc>().state.currentAudioIndex !=
                      null
              ? context.read<AudioPlayerBloc>().state.currentAudioIndex as int
              : bookmarkedVerseIndex() ?? 0,
          itemBuilder: (context, verseIndex) {
            return BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, bookmarkState) {
                return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, audioPlayerState) {
                    return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
                      builder: (context, surahTrackerState) {
                        return AyahOnClickButton(
                          themeState: widget.themeBloc.state,
                          verseIndex: verseIndex,
                          surahId: widget.surahId,
                          quranDisplayType: QuranDisplayType.surah,
                          child: Column(
                            children: [
                              // surah info
                              if (verseIndex == 0)
                                Utils.surahTopInfo(
                                    context: context,
                                    surahIndex: widget.surahId - 1),
                              // Display the Bismillah at the start of the Surah.
                              if (verseIndex == 0 &&
                                  widget.surahId != 1 &&
                                  widget.surahId != 9)
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              (verseIndex + 1).toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),

                                        // bookmark icon
                                        if (bookmarkState
                                                    .lastRead["verse_index"] ==
                                                verseIndex &&
                                            bookmarkState
                                                    .lastRead["surah_index"] ==
                                                widget.surahId - 1)
                                          const Icon(
                                            Icons.bookmark_added_rounded,
                                          ),

                                        // favourite icon
                                        if (bookmarkState.favourites.any(
                                            (fav) =>
                                                fav["surahIndex"] ==
                                                    widget.surahId - 1 &&
                                                fav["verseIndex"] ==
                                                    verseIndex))
                                          const Icon(
                                            Icons.star_rounded,
                                          ),

                                        // bookmark icon
                                        if (audioPlayerState.quranDisplayType ==
                                                QuranDisplayType.surah &&
                                            audioPlayerState
                                                    .currentSurahOrJuzId ==
                                                widget.surahId.toString() &&
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
                                            textDirection: TextDirection.rtl,
                                            spacing: Utils.wordSpacingSettings(
                                                settingsState: settingsState),
                                            children: [
                                              for (int wordIndex = 0;
                                                  wordIndex <
                                                      widget
                                                          .surahData[verseIndex]
                                                              ["words"]
                                                          .length;
                                                  wordIndex++)
                                                // TOOL TIP
                                                Tooltip(
                                                    decoration:
                                                        Utils.toolTipDecoration(
                                                            context: context),
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white),
                                                    triggerMode:
                                                        TooltipTriggerMode.tap,
                                                    preferBelow: false,
                                                    showDuration: const Duration(
                                                        seconds: 10),

                                                    // when tool tip is triggered it will also highlight the word
                                                    onTriggered: () async {
                                                      // Handle the tap for the specific word

                                                      context
                                                          .read<
                                                              SurahTrackerBloc>()
                                                          .add(UpdateHighlightWordEvent(
                                                              wordLocation: widget
                                                                              .surahData[verseIndex]
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
                                                                "https://audio.qurancdn.com/${widget.surahData[verseIndex]["words"][wordIndex]["audio_url"]}"));
                                                      }
                                                    },
                                                    message: widget.surahData[verseIndex]
                                                            ["words"][wordIndex]
                                                        ["translation"]["text"],
                                                    child:
                                                        settingsState.selectedQuranScriptType ==
                                                                "tajweed"
                                                            ? Container(
                                                                // highlight word images
                                                                color: Utils.highlightTajweedWordImage(
                                                                    context:
                                                                        context,
                                                                    quranDisplayType:
                                                                        QuranDisplayType
                                                                            .surah,
                                                                    audioPlayerQuranDisplayType:
                                                                        audioPlayerState
                                                                            .quranDisplayType,
                                                                    audioPlayerHighlightedWordLocation:
                                                                        audioPlayerState
                                                                            .highlightWordLocation,
                                                                    currentWordLocation:
                                                                        widget.surahData[verseIndex]["words"][wordIndex]
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
                                                                        verseIndex,
                                                                    settingsState:
                                                                        settingsState,
                                                                    surahId: widget
                                                                        .surahId,
                                                                    wordsLength: widget
                                                                        .surahData[
                                                                            verseIndex]
                                                                            [
                                                                            "words"]
                                                                        .length),
                                                              )
                                                            : Utils.displayWordText(
                                                                data: widget.surahData,
                                                                context: context,
                                                                verseIndex: verseIndex,
                                                                wordIndex: wordIndex,
                                                                settingsState: settingsState,
                                                                audioPlayerState: audioPlayerState,
                                                                surahTrackerState: surahTrackerState,
                                                                quranDisplayType: QuranDisplayType.surah)),
                                            ],
                                          ),

                                          // Display the verse translation and transliteration
                                          Utils
                                              .displayVerseTransliterationAndTranslation(
                                            surahOrJuzData: widget.surahData,
                                            verseTranslation: widget
                                                    .translatedData[verseIndex]
                                                ["text"],
                                            verseIndex: verseIndex,
                                            settingsState: settingsState,
                                            context: context,
                                          ),

                                          if (widget.surahData[verseIndex]
                                                  ["sajdah_number"] !=
                                              null)
                                            Text(
                                              "-- Sajdah (prostrate) --",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(color: Colors.red),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

// Widget displayWordText(
//     int verseIndex,
//     int wordIndex,
//     SettingsState settingsState,
//     AudioPlayerState audioPlayerState,
//     SurahTrackerState surahTrackerState,
//     BuildContext context) {
//   return Text(
//     widget.surahData[verseIndex]["words"][wordIndex][Utils.quranScriptName(
//             quranScriptName: settingsState.selectedQuranScriptType)]
//         .toString(),
//     style: TextStyle(
//       locale: const Locale("ar"),
//       fontFamily: "${settingsState.selectedQuranScriptType}_font",
//       fontSize: settingsState.quranTextFontSize.sp,
//       height: 1.55,
//       color: Utils.highlightTextWords(
//         audioPlayerHighlightedWordLocation:
//             audioPlayerState.highlightWordLocation,
//         surahTrackerHighlightedWordLocation: surahTrackerState.highlightWord,
//         quranDisplayType: QuranDisplayType.surah,
//         audioPlayerQuranDisplayType: audioPlayerState.quranDisplayType,
//         currentWordLocation: widget.surahData[verseIndex]["words"][wordIndex]
//             ["location"],
//         context: context,
//       ),
//     ),
//     textAlign: TextAlign.right,
//     textDirection: TextDirection.rtl,
//   );
// }
}
