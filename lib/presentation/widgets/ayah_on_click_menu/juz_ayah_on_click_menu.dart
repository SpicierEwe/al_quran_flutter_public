import 'package:al_quran_new/core/utils/ayah_on_click_utils.dart';
import 'package:al_quran_new/logic/audio_player_bloc/audio_player_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/custom_themes.dart';
import '../../../core/constants/enums.dart';
import '../../../logic/bookmark_bloc/bookmark_bloc.dart';
import '../../../logic/surah_names_bloc/surah_names_bloc.dart';

class JuzAyahOnClickButton extends StatefulWidget {
  final Widget child;
  final int verseIndex;
  final int actualVerseIndex;
  final int surahId;
  final int juzId;
  final QuranDisplayType quranDisplayType;

  const JuzAyahOnClickButton(
      {super.key,
      required this.quranDisplayType,
      required this.actualVerseIndex,
      required this.juzId,
      required this.child,
      required this.verseIndex,
      required this.surahId});

  @override
  State<JuzAyahOnClickButton> createState() => _JuzAyahOnClickButtonState();
}

class _JuzAyahOnClickButtonState extends State<JuzAyahOnClickButton> {
  late List<Map<String, dynamic>> features;
  late List<Map<String, dynamic>> additionalFeatures;

  @override
  void initState() {
    features = [
      {
        "name": "Play Audio",
        "icon": Icons.volume_up_rounded,
        "onPressed": () {
          Logger().i("Play Audio : ${widget.verseIndex + 1}");

          if (context.read<AudioPlayerBloc>().state.quranDisplayType ==
                  widget.quranDisplayType &&
              context.read<AudioPlayerBloc>().state.isAudioPlaying &&
              context.read<AudioPlayerBloc>().state.currentSurahOrJuzId ==
                  (widget.juzId).toString()) {
            context
                .read<AudioPlayerBloc>()
                .add(SeekToSpecificVerseDuringPlayingEvent(
                  verseIndex: widget.verseIndex,
                ));
          } else {
            context.read<AudioPlayerBloc>().add(LoadAudioEvent(
                  quranDisplayType: widget.quranDisplayType,
                  reciterId:
                      context.read<SettingsBloc>().state.selectedReciterId,
                  surahOrJuzId: widget.juzId.toString(),
                  playFromVerseIndex: widget.verseIndex,
                ));
          }

          context.pop();
        },
      },
      {
        "name": "Read Tafsir",
        "icon": Icons.menu_book_rounded,
        "onPressed": () {},
      },
      {
        "name": "Mark as Last Read",
        "icon": Icons.bookmark_add_outlined,
        "onPressed": () {
          context.read<BookmarkBloc>().add(AddBookmarkEvent(
                bookmarkType: BookmarkType.juz,
                surahIndex: widget.surahId - 1,
                verseIndex: widget.actualVerseIndex,
              ));
          context.pop();
        },
      },
      {
        "name": "Add to favourites",
        "icon": Icons.star_outline_rounded,
        "onPressed": () {
          context.read<BookmarkBloc>().add(AddToFavouritesEvent(
                surahIndex: widget.surahId - 1,
                verseIndex: widget.actualVerseIndex,
              ));
          context.pop();
        },
      },
      {
        "name": "Settings",
        "icon": Icons.settings_rounded,
        "onPressed": () {},
      },
    ];

    additionalFeatures = [
      {
        "name": "Copy",
        "icon": Icons.copy_rounded,
        "onPressed": () {},
      },
      {
        "name": "Share",
        "icon": Icons.share_rounded,
        "onPressed": () {},
      },
      {
        "name": "Download Verse Audio",
        "icon": Icons.download_rounded,
        "onPressed": () {},
      },
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          textStyle: null,
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          backgroundColor: widget.verseIndex % 2 != 0
              ? MaterialStatePropertyAll(
                  CustomThemes.verseStripesColor(context: context))
              : MaterialStateProperty.all(
                  Theme.of(context).colorScheme.background),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                        ),
                        child: Text(
                            '${context.read<SurahNamesBloc>().state.surahNamesMetaData![widget.surahId - 1]["name_complex"]} : ${widget.surahId} | verse ${widget.actualVerseIndex + 1}',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                      ),

                      // Features
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < features.length; i++)
                            Column(
                              children: [
                                if (i == 2) showBookmarked(),
                                if (i == 3) showFavourite(),
                                if (i != 2 && i != 3)
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                      ),
                                      padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(
                                          vertical: 1.h,
                                          horizontal: 5.w,
                                        ),
                                      ),
                                    ),
                                    onPressed: features[i]["onPressed"],
                                    child: Row(
                                      children: [
                                        Icon(
                                          features[i]["icon"],
                                          size: 21.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        Text(
                                          features[i]["name"],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),

                      // Additional Features

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < additionalFeatures.length; i++)
                            IconButton(
                              onPressed: () {
                                print(additionalFeatures[i]["name"]);
                              },
                              icon: Icon(
                                additionalFeatures[i]["icon"],
                                size: 18.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        },
        child: widget.child);
  }

  // show favourite
  Widget showFavourite() {
    const int i = 3;
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, bookmarkState) {
        bool isFavourite = bookmarkState.favourites.any((element) =>
            element["surahIndex"] == widget.surahId - 1 &&
            element["verseIndex"] == widget.actualVerseIndex);

        // if favourite show remove from favourite option
        if (isFavourite) {
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: () {
              context.read<BookmarkBloc>().add(RemoveFromFavouritesEvent(
                    surahIndex: widget.surahId - 1,
                    verseIndex: widget.actualVerseIndex,
                  ));
              context.pop();
            },
            child: Row(
              children: [
                Icon(
                  Icons.remove_circle_rounded,
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Remove from Favourites",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else {
          // if not favourite show add to favourite option
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: features[i]["onPressed"],
            child: Row(
              children: [
                Icon(
                  features[i]["icon"],
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  features[i]["name"],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // show favourite
  Widget showBookmarked() {
    const int i = 2;
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        // if bookmark show remove bookmark option
        if (state.lastRead["juz_index"] == widget.juzId - 1 &&
            state.lastRead["verse_index"] == widget.actualVerseIndex &&
            state.lastRead["surah_index"] == widget.surahId - 1) {
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: () {
              context.read<BookmarkBloc>().add(RemoveBookmarkEvent());
              context.pop();
            },
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_remove_rounded,
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Remove from Last Read",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else {
          // if not bookmark show add bookmark option
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: features[i]["onPressed"],
            child: Row(
              children: [
                Icon(
                  features[i]["icon"],
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  features[i]["name"],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
