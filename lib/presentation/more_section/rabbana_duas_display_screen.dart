import 'package:al_quran_new/core/constants/rabbana_duas.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/utils.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/bookmark_bloc/bookmark_bloc.dart';
import '../../logic/surah_tracker_bloc/surah_tracker_bloc.dart';

class RabbanaDuasDisplayScreen extends StatefulWidget {
  const RabbanaDuasDisplayScreen({super.key});

  @override
  State<RabbanaDuasDisplayScreen> createState() =>
      _RabbanaDuasDisplayScreenState();
}

class _RabbanaDuasDisplayScreenState extends State<RabbanaDuasDisplayScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
      builder: (context, surahTrackerState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Rabbana Duas"),
              ),
              body: ListView.builder(
                // padding at the bottom of the list
                padding: EdgeInsets.only(
                  bottom: 2.1.h,
                ),
                shrinkWrap: true,
                itemCount: DuasClass.rabbanaDuasList.length,
                itemBuilder: (context, index) {
                  final duasList = DuasClass.rabbanaDuasList;
                  final int surahIndex = duasList[index][0] - 1;
                  final int verseIndex = duasList[index][1] - 1;

                  final List<dynamic> surahData =
                      LocalDataRepository.getStoredQuranArabicChapter(
                          chapterId: surahIndex + 1)!;

                  final String verseTranslation =
                      LocalDataRepository.getStoredQuranChapterTranslation(
                          chapterId: surahIndex + 1,
                          translationId: settingsState
                              .selectedTranslationId)![verseIndex]["text"];
                  return Column(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: () {
                          context.read<BookmarkBloc>().add(
                              RedirectToFavouriteEvent(
                                  verseIndex: verseIndex,
                                  surahIndex: surahIndex));

                          context.push(
                            '/surah_display_screen',
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // surah name
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.7.w,
                                    vertical: .7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text("Dua ${index + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Container(
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // surah name
                                  Text(
                                      "${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahIndex]["name_complex"]} | ${surahIndex + 1} : ${verseIndex + 1}",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),

                            SizedBox(height: 2.1.h),

                            //   verse display
                            Utils.displaySingleVerseWithTranslation(
                              settingsState: settingsState,
                              verseIndex: verseIndex,
                              context: context,
                              surahTrackerState: surahTrackerState,
                              surahIndex: surahIndex,
                            ),

                            if (index != duasList.length - 1)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                child: SizedBox(
                                  height: 1.5.h,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
