import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../../logic/language_bloc/language_bloc.dart';
import '../../../logic/surah_names_bloc/surah_names_bloc.dart';
import '../../../logic/theme_bloc/theme_bloc.dart';

class SurahNamesWidget extends StatefulWidget {
  const SurahNamesWidget({super.key});

  @override
  State<SurahNamesWidget> createState() => _SurahNamesWidgetState();
}

class _SurahNamesWidgetState extends State<SurahNamesWidget> {
  List<int> searchAbleSurahIds = [];

  void querySearch({required String queryValue, required List<dynamic> data}) {
    List<int> results = [];
    for (var item in data) {
      for (var key in item.keys) {
        if (item[key]
            .toString()
            .toLowerCase()
            .contains(queryValue.toLowerCase())) {
          results.add(item["id"]);
        }
      }
    }

    Logger().i("Results: $results");
    setState(() {
      searchAbleSurahIds = results.toSet().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioPlayerState) {
        return BlocBuilder<DownloaderBloc, DownloaderState>(
          builder: (context, downloaderBlocState) {
            if (downloaderBlocState.surahNamesMetaData == null) {
              return const LoadingWidget();
            }
            List surahNamesMetaData = downloaderBlocState.surahNamesMetaData!;
            searchAbleSurahIds =
                surahNamesMetaData.map((e) => e["id"] as int).toList();

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 1.h),
                      itemCount: surahNamesMetaData.length,
                      itemBuilder: (context, index) {
                        return Builder(
                          builder: (context) {
                            // Use Builder to create a new build context

                            return Column(
                              children: [
                                if (index == 0)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.5.h,
                                    ),
                                    child: SearchAnchor(
                                      viewOnChanged: (queryValue) {
                                        Logger().i("Query: $queryValue");
                                        querySearch(
                                            queryValue: queryValue,
                                            data: surahNamesMetaData);
                                      },

                                      // ============
                                      isFullScreen: true,
                                      viewSurfaceTintColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      builder: (BuildContext context,
                                          SearchController controller) {
                                        return SearchBar(
                                          hintText: "Search Surah",
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          surfaceTintColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          elevation:
                                              MaterialStateProperty.all(1),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                      .withOpacity(.5)),
                                          controller: controller,
                                          padding:
                                              const MaterialStatePropertyAll<
                                                      EdgeInsets>(
                                                  EdgeInsets.symmetric(
                                                      horizontal: 16.0)),
                                          onTap: () {
                                            controller.openView();
                                          },
                                          onChanged: (queryValue) {
                                            controller.openView();
                                          },
                                          leading: IconButton(
                                            icon: const Icon(
                                                Icons.search_rounded),
                                            onPressed: () {
                                              controller.openView();
                                            },
                                          ),
                                        );
                                      },
                                      suggestionsBuilder: (BuildContext context,
                                          SearchController controller) {
                                        final List<int>
                                            surahSuggestionsIdsList = [
                                          67,
                                          36,
                                          2,
                                          18,
                                          56,
                                          19,
                                        ];

                                        return List.generate(
                                          searchAbleSurahIds.length,
                                          (int index) {
                                            /*
                                            * What is actual surah index
                                            *
                                            * The searchAbleSurahIds is a list of surah ids
                                            * The above index is the index of the searchAbleSurahIds list which doesn't refer to the actual surah index.
                                            *
                                            * so we take the id at that index and subtract 1 to get the actual surah index
                                            * */
                                            int actualSurahIndex =
                                                searchAbleSurahIds[index] - 1;
                                            return Column(
                                              children: [
                                                if (index == 0)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 1.3.w,
                                                      vertical: 1.5.h,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Commonly Searched",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Wrap(
                                                            children:
                                                                List.generate(
                                                                    surahSuggestionsIdsList
                                                                        .length,
                                                                    (index) =>
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(right: 1.5.w),
                                                                          child:

                                                                              // SUGGESTIONS CHIP
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              context.read<SurahDisplayBloc>().add(SelectedSurahNumberEvent(selectedSurahNumber: surahSuggestionsIdsList[index]));
                                                                              context.go(
                                                                                "/surah_display_screen",
                                                                              );
                                                                            },
                                                                            child:
                                                                                Chip(
                                                                              label: Text(surahNamesMetaData[surahSuggestionsIdsList[index] - 1]["name_complex"], style: Theme.of(context).textTheme.bodyMedium),
                                                                            ),
                                                                          ),
                                                                        ))),
                                                      ],
                                                    ),
                                                  ),
                                                surahItem(
                                                    context,
                                                    surahNamesMetaData,
                                                    actualSurahIndex,
                                                    audioPlayerState),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                surahItem(context, surahNamesMetaData, index,
                                    audioPlayerState),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TextButton surahItem(
      BuildContext context,
      List<dynamic> surahNamesMetaDataState,
      int index,
      AudioPlayerState audioPlayerState) {
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
        context.read<SurahDisplayBloc>().add(SelectedSurahNumberEvent(
            selectedSurahNumber: surahNamesMetaDataState[index]["id"] as int));
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
                          surahNamesMetaDataState[index]["name_complex"]
                              .toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      // ======================
                      if (audioPlayerState.quranDisplayType ==
                              QuranDisplayType.surah &&
                          audioPlayerState.currentSurahOrJuzId ==
                              surahNamesMetaDataState[index]["id"].toString())
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
                    surahNamesMetaDataState[index]["translated_name"]["name"]
                        .toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
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
  }
}
