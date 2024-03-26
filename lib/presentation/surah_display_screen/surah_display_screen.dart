import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/config_bloc/config_bloc.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:al_quran_new/logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import 'package:al_quran_new/presentation/settings_screens/settings_screen.dart';
import 'package:al_quran_new/presentation/surah_display_screen/widgets/surah_mushaf_mode_widget.dart';
import 'package:al_quran_new/presentation/surah_display_screen/widgets/surah_verseByVerseWidget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants/enums.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/bookmark_bloc/bookmark_bloc.dart';
import '../../logic/display_type_switcher_bloc/display_type_switcher_bloc.dart';
import '../../logic/repositories/local_data_repository.dart';
import '../../logic/surah_display_bloc/surah_display_bloc.dart';
import '../../logic/theme_bloc/theme_bloc.dart';

/// The screen for displaying a Surah with highlighted words.
class SurahDisplayScreen extends StatefulWidget {
  const SurahDisplayScreen({Key? key}) : super(key: key);

  @override
  State<SurahDisplayScreen> createState() => _SurahDisplayScreenState();
}

class _SurahDisplayScreenState extends State<SurahDisplayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 114,
        vsync: this,
        initialIndex:
            114 - context.read<SurahDisplayBloc>().state.selectedSurahNumber!);

    // sending tab controller to the audio player bloc
    context.read<AudioPlayerBloc>().add(SurahGetTabControllerAudioPLayerEvent(
          surahTabController: _tabController,
        ));

    context.read<SurahDisplayBloc>().add(DisplaySurahEvent(
          selectedSurahNumber: 114 - _tabController.index,
          selectedTranslationId:
              context.read<SettingsBloc>().state.selectedTranslationId,
        ));
    _tabController.addListener(() {
      context.read<SurahDisplayBloc>().add(SelectedSurahNumberEvent(
          selectedSurahNumber: 114 - _tabController.index));

      context.read<SurahDisplayBloc>().add(DisplaySurahEvent(
            selectedSurahNumber: 114 - _tabController.index,
            selectedTranslationId:
                context.read<SettingsBloc>().state.selectedTranslationId,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.of<ThemeBloc>(context);
    final surahDisplayBloc = BlocProvider.of<SurahDisplayBloc>(context);

    return DefaultTabController(
      length: 114,
      initialIndex: 114 - surahDisplayBloc.state.selectedSurahNumber!,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<SurahDisplayBloc, SurahDisplayState>(
              builder: (context, surahDisplayState) {
                return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, audioPlayerState) {
                    return IconButton(
                      onPressed: () {
                        // todo : implement dynamic reciterID

                        context.read<AudioPlayerBloc>().add(LoadAudioEvent(
                              quranDisplayType: QuranDisplayType.surah,
                              surahOrJuzId: surahDisplayState
                                  .selectedSurahNumber
                                  .toString(),
                              reciterId: context
                                  .read<SettingsBloc>()
                                  .state
                                  .selectedReciterId,
                            ));
                        // context.read<AudioPlayerBloc>().add(PlayPauseEvent());
                      },
                      icon: audioPlayerState.isAudioPlaying &&
                              audioPlayerState.currentSurahOrJuzId ==
                                  surahDisplayState.selectedSurahNumber
                                      .toString()
                          ? const Icon(Icons.pause_rounded)
                          : const Icon(Icons.play_arrow_rounded),
                    );
                  },
                );
              },
            ),
            IconButton(
              onPressed: () {
                context
                    .read<DisplayTypeSwitcherBloc>()
                    .add(UpdateMushafModeEvent());
              },
              icon: const Icon(Icons.menu_book_rounded),
            ),
            IconButton(
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          title: BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
            builder: (context, state) {
              return Text(
                "Pg ${state.pageHizbManzilData[0]} | Hzb ${state.pageHizbManzilData[1]}",
                style: Theme.of(context).textTheme.titleMedium,
              );
            },
          ),
          // TABBAR
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.center,
            tabs: [
              for (int surahTabId = 114; surahTabId > 0; surahTabId--)
                Tab(
                  child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                    builder: (context, audioPlayerState) {
                      return Row(
                        children: [
                          if (audioPlayerState.quranDisplayType ==
                                  QuranDisplayType.surah &&
                              audioPlayerState.currentSurahOrJuzId ==
                                  surahTabId.toString())
                            const Icon(Icons.volume_up_rounded),
                          SizedBox(width: 1.5.w),
                          Text(
                            "$surahTabId. ${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahTabId - 1]["name_complex"]}",
                          )
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
            114,
            // for (int surahId = 114; surahId > 0; surahId--)
          (index) =>     _buildSurahPage(114-index, themeBloc),


      ),
    ),
    )
    );
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildSurahPage(int surahId, ThemeBloc themeBloc) {
    return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                return BlocBuilder<SurahDisplayBloc, SurahDisplayState>(
                  builder: (context, state) {
                    // If the surah data or the translation data is not available, then fetch the data.
                    if (state.surahData == null ||
                        state.chapterTranslationData == null) {
                      return const LoadingWidget();
                    }

                    final List surahData =
                        LocalDataRepository.getStoredQuranArabicChapter(
                      chapterId: surahId,
                    )!;

                    final List translatedData =
                        LocalDataRepository.getStoredQuranChapterTranslation(
                      chapterId: surahId,
                      translationId: settingsState.selectedTranslationId,
                    )!;

                    List pages = surahData
                        .map((e) => e["page_number"])
                        .toSet()
                        .toList();

                    // Logger().i("pages  : " + pages.toString());

                    // Build a ListView displaying the Surah verses.
                    return BlocBuilder<DisplayTypeSwitcherBloc,
                        DisplayTypeSwitcherState>(
                      builder: (context, state) {
                        if (state.isMushafMode) {
                          return SurahMushafModeWidget(
                            surahData: surahData,
                            pages: pages,
                            surahId: surahId,
                            themeBloc: themeBloc,
                            player: player,
                          );
                        }

                        return SurahVerseByVerseMode(
                            surahData: surahData,
                            surahId: surahId,
                            themeBloc: themeBloc,
                            player: player,
                            translatedData: translatedData);
                      },
                    );
                  },
                );
              },
            );
  }
}
