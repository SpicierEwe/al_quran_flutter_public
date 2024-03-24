import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/config_bloc/config_bloc.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/juz_display_bloc/juz_display_bloc.dart';
import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:al_quran_new/logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import 'package:al_quran_new/presentation/juz_display_screen/widgets/juz_mushaf_mode_widget.dart';
import 'package:al_quran_new/presentation/juz_display_screen/widgets/juz_verse_by_verse_widget.dart';
import 'package:al_quran_new/presentation/settings_screens/settings_screen.dart';
import 'package:al_quran_new/presentation/surah_display_screen/widgets/surah_mushaf_mode_widget.dart';
import 'package:al_quran_new/presentation/surah_display_screen/widgets/surah_verseByVerseWidget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants/enums.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/display_type_switcher_bloc/display_type_switcher_bloc.dart';
import '../../logic/repositories/local_data_repository.dart';
import '../../logic/surah_display_bloc/surah_display_bloc.dart';
import '../../logic/theme_bloc/theme_bloc.dart';

/// The screen for displaying a Surah with highlighted words.
class JuzDisplayScreen extends StatefulWidget {
  const JuzDisplayScreen({Key? key}) : super(key: key);

  @override
  State<JuzDisplayScreen> createState() => _SurahDisplayScreenState();
}

class _SurahDisplayScreenState extends State<JuzDisplayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: AppVariables.juzMetaData.length,
        vsync: this,
        initialIndex: AppVariables.juzMetaData.length -
            (context.read<JuzDisplayBloc>().state.selectedJuzId!));

    // sending tab controller to the audio player bloc
    context.read<AudioPlayerBloc>().add(JuzGetTabControllerAudioPLayerEvent(
          juzTabController: _tabController,
        ));

    // loading juz data
    context.read<JuzDisplayBloc>().add(DisplayJuzEvent(
          selectedJuzNumber:
              AppVariables.juzMetaData.length - _tabController.index,
          selectedTranslationId:
              context.read<SettingsBloc>().state.selectedTranslationId,
        ));

    // Add a listener to the tabController to listen to the tab change
    _tabController.addListener(() {
      context.read<JuzDisplayBloc>().add(UpdateSelectedJuzId(
          selectedJuzId:
              AppVariables.juzMetaData.length - _tabController.index));

      context.read<JuzDisplayBloc>().add(DisplayJuzEvent(
            selectedJuzNumber:
                AppVariables.juzMetaData.length - _tabController.index,
            selectedTranslationId:
                context.read<SettingsBloc>().state.selectedTranslationId,
          ));
    });

    // Add a listener to the itemPositionsListener to listen to the scroll position
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.of<ThemeBloc>(context);
    final juzDisplayBloc = BlocProvider.of<JuzDisplayBloc>(context);

    return DefaultTabController(
      length: AppVariables.juzMetaData.length,
      initialIndex: AppVariables.juzMetaData.length -
          (juzDisplayBloc.state.selectedJuzId!),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<JuzDisplayBloc, JuzDisplayState>(
              builder: (context, juzDisplayState) {
                return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, audioPlayerState) {
                    return IconButton(
                      onPressed: () {
                        Logger().i(
                            "App bar play button audio juzID : ${context.read<JuzDisplayBloc>().state.selectedJuzId}");
                        context.read<AudioPlayerBloc>().add(LoadAudioEvent(
                              quranDisplayType: QuranDisplayType.juz,
                              surahOrJuzId: (context
                                      .read<JuzDisplayBloc>()
                                      .state
                                      .selectedJuzId!)
                                  .toString(),
                              reciterId: context
                                  .read<SettingsBloc>()
                                  .state
                                  .selectedReciterId,
                            ));
                        // context.read<AudioPlayerBloc>().add(PlayPauseEvent());
                      },
                      icon: audioPlayerState.quranDisplayType ==
                                  QuranDisplayType.juz &&
                              audioPlayerState.isAudioPlaying &&
                              audioPlayerState.currentSurahOrJuzId ==
                                  juzDisplayState.selectedJuzId.toString()
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
          title:

              // BlocBuilder<SurahDisplayBloc, SurahDisplayState>(
              //   builder: (context, state) {
              //     return Text("sdsd");
              //   },
              // ),

              BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
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
              for (int juzTabId = AppVariables.juzMetaData.length;
                  juzTabId > 0;
                  juzTabId--)
                Tab(
                  child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                    builder: (context, audioPlayerState) {
                      return Row(
                        children: [
                          if (audioPlayerState.quranDisplayType ==
                                  QuranDisplayType.juz &&
                              audioPlayerState.currentSurahOrJuzId ==
                                  juzTabId.toString() &&
                              audioPlayerState.isAudioPlaying)
                            const Icon(Icons.volume_up_rounded),
                          SizedBox(width: 1.5.w),
                          Text(
                            "Juz $juzTabId",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
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
          children: [
            for (int juzId = AppVariables.juzMetaData.length;
                juzId > 0;
                juzId--)
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return BlocBuilder<JuzDisplayBloc, JuzDisplayState>(
                    builder: (context, state) {
                      // If the surah data or the translation data is not available, then fetch the data.
                      if (state.juzData == null ||
                          state.juzTranslationData == null) {
                        return const LoadingWidget();

                        //   todo : implement using tabcontroller
                      }
                      final Map<String, String> juzMetaData =
                          AppVariables.juzMetaData[juzId - 1]["verse_mapping"];

                      final List juzData = [];
                      final List juzTranslatedData = [];
                      juzMetaData.forEach((key, value) {
                        int keyInt = int.parse(key);
                        int verseStart = int.parse(value.split("-")[0]);
                        int verseEnd = int.parse(value.split("-")[1]);
                        String keyValue = value;
                        print("key : $key, value : $value");

                        final List surahDataTemp =
                            LocalDataRepository.getStoredQuranArabicChapter(
                          chapterId: keyInt,
                        )!;

                        final List translatedDataTemp = LocalDataRepository
                            .getStoredQuranChapterTranslation(
                          chapterId: keyInt,
                          translationId: settingsState.selectedTranslationId,
                        )!;

                        juzData.addAll(
                            surahDataTemp.sublist(verseStart - 1, verseEnd));
                        juzTranslatedData.addAll(translatedDataTemp.sublist(
                            verseStart - 1, verseEnd));
                      });

                      List pages =
                          juzData.map((e) => e["page_number"]).toSet().toList();

                      // Logger().i("pages  : " + pages.toString());

                      // Build a ListView displaying the Surah verses.
                      return BlocBuilder<DisplayTypeSwitcherBloc,
                          DisplayTypeSwitcherState>(
                        builder: (context, state) {
                          if (state.isMushafMode) {
                            return JuzMushafModeWidget(
                              juzData: juzData,
                              pages: pages,
                              juzId: juzId,
                              themeBloc: themeBloc,
                              player: player,
                            );
                          }

                          return JuzVerseByVerseMode(
                              juzData: juzData,
                              juzId: juzId,
                              themeBloc: themeBloc,
                              player: player,
                              translatedData: juzTranslatedData);
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
