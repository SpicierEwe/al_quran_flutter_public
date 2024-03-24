import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../../logic/language_bloc/language_bloc.dart';
import '../../../logic/surah_names_bloc/surah_names_bloc.dart';
import '../../../logic/theme_bloc/theme_bloc.dart';

class SurahNamesWidget extends StatelessWidget {
  const SurahNamesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioPlayerState) {
        return BlocBuilder<DownloaderBloc, DownloaderState>(
          builder: (context, downloaderBlocState) {
            final surahNamesMetaDataState =
                downloaderBlocState.surahNamesMetaData;
            if (downloaderBlocState.surahNamesMetaData == null) {
              return const LoadingWidget();
            }

            return ListView.builder(
              padding: EdgeInsets.only(top: 1.h),
              itemCount: surahNamesMetaDataState!.length,
              itemBuilder: (context, index) {
                return Builder(
                  builder: (context) {
                    // Use Builder to create a new build context
                    return TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: .5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      // surah onPressed Name
                      onPressed: () {
                        context.read<SurahDisplayBloc>().add(
                            SelectedSurahNumberEvent(
                                selectedSurahNumber:
                                    surahNamesMetaDataState[index]["id"]
                                        as int));
                        context.go(
                          "/surah_display_screen",
                        );
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Utils.displaySurahOrJuzNumber(
                              surahNumber: index + 1, context: context),
                          // TRANSLATED NAME
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          surahNamesMetaDataState[index]
                                                  ["name_complex"]
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      // ======================
                                      if (audioPlayerState.quranDisplayType ==
                                              QuranDisplayType.surah &&
                                          audioPlayerState
                                                  .currentSurahOrJuzId ==
                                              surahNamesMetaDataState[index]
                                                      ["id"]
                                                  .toString())
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.multitrack_audio_rounded,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: .7.h),
                                  Text(
                                    surahNamesMetaDataState[index]
                                            ["translated_name"]["name"]
                                        .toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Column(
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Utils.displaySurahNamesArabicIcon(
                                      context: context, surahIndex: index),
                                ),
                                Text(
                                  "${surahNamesMetaDataState[index]["verses_count"]} Verses",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
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
  }
}
