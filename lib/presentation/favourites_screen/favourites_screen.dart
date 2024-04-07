import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
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

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
      builder: (context, surahTrackerState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, bookmarkState) {
                // if there are no favourites
                if (bookmarkState.favourites.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text("Favourites"),
                    ),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_border_rounded,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "No Favourites",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Text(
                              "To add a verse to favourite, click on the verse then select add to favorites.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // if there are favourites
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Favourites"),
                  ),
                  body: ListView.builder(
                    // padding at the bottom of the list
                    padding: EdgeInsets.only(
                      bottom: 2.1.h,
                    ),
                    shrinkWrap: true,
                    itemCount: bookmarkState.favourites.length,
                    itemBuilder: (context, index) {
                      final int surahIndex =
                          bookmarkState.favourites[index]["surahIndex"];
                      final int verseIndex =
                          bookmarkState.favourites[index]["verseIndex"];
                      //
                      // final List<dynamic> surahData =
                      //     LocalDataRepository.getStoredQuranArabicChapter(
                      //         chapterId: surahIndex + 1)!;
                      //
                      // final String verseTranslation =
                      //     LocalDataRepository.getStoredQuranChapterTranslation(
                      //         chapterId: surahIndex + 1,
                      //         translationId: settingsState
                      //             .selectedTranslationId)![verseIndex]["text"];
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // index number
                                    CircleAvatar(
                                      radius: 15,
                                      child: Text("${index + 1}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),

                                    // surah name
                                    Text(
                                        "${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahIndex]["name_complex"]} | ${surahIndex + 1} : ${verseIndex + 1}"),

                                    // remove button
                                    IconButton(
                                        onPressed: () {
                                          context.read<BookmarkBloc>().add(
                                              RemoveFromFavouritesEvent(
                                                  surahIndex: surahIndex,
                                                  verseIndex: verseIndex));
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_rounded,
                                          color: Colors.red,
                                        )),
                                  ],
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

                                // verse translation
                              ],
                            ),
                          ),
                          if (index != bookmarkState.favourites.length - 1)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                              ),
                              child: const Divider(),
                            )
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
