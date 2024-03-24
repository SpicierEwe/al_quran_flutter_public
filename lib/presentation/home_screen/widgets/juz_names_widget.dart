import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/juz_display_bloc/juz_display_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/enums.dart';
import '../../../core/utils/utils.dart';
import '../../../logic/audio_player_bloc/audio_player_bloc.dart';

class JuzNamesWidget extends StatefulWidget {
  const JuzNamesWidget({super.key});

  @override
  State<JuzNamesWidget> createState() => _JuzNamesWidgetState();
}

class _JuzNamesWidgetState extends State<JuzNamesWidget> {
  late List<bool> isExpandedList;

  @override
  void initState() {
    // Initialize isExpandedList with false for each Juz
    isExpandedList =
        List<bool>.generate(AppVariables.juzMetaData.length, (_) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioPlayerState) {
        return ListView.builder(
          itemCount: AppVariables.juzMetaData.length,
          itemBuilder: (context, index) {
            return TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.5.w,
                  vertical: .5.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              // surah onPressed Name
              onPressed: () {
                context.read<JuzDisplayBloc>().add(
                      UpdateSelectedJuzId(selectedJuzId: index + 1),
                    );

                context.push('/juz_display_screen');
              },

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Utils.displaySurahOrJuzNumber(
                          surahNumber: index + 1, context: context),
                      SizedBox(width: 3.w),

                      // TRANSLATED NAME

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: .55.h,
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 5.w),
                              title: Row(
                                children: [
                                  Text(
                                    "Juz ${index + 1}",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  // ======================
                                  if (audioPlayerState.quranDisplayType ==
                                          QuranDisplayType.juz &&
                                      audioPlayerState.currentSurahOrJuzId ==
                                          (index + 1).toString())
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.multitrack_audio_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),

                              // start and end
                              subtitle: startAndEnd(juzIndex: index),

                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  setState(() {
                                    isExpandedList[index] =
                                        !isExpandedList[index];
                                  });
                                },
                              ),
                            ),

                            // VERSE MAPPING ============ ( minimizable / expandable )
                            if (isExpandedList[index])
                              AnimatedContainer(
                                // height: isExpandedList[index] ? null : 0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                child: Padding(
                                  padding: EdgeInsets.only(top: .5.h),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: AppVariables
                                        .juzMetaData[index]["verse_mapping"]
                                        .length,
                                    itemBuilder: (context, i) {
                                      var verseMapping = AppVariables
                                          .juzMetaData[index]["verse_mapping"];

                                      String surahNumber =
                                          (verseMapping.keys.elementAt(i));
                                      int surahIndex =
                                          int.parse(surahNumber) - 1;
                                      String verseValue =
                                          verseMapping[surahNumber];
                                      String surahName = context
                                              .read<SurahNamesBloc>()
                                              .state
                                              .surahNamesMetaData?[surahIndex]
                                          ["name_complex"];
                                      return ListTile(
                                        leading: Utils.displaySurahOrJuzNumber(
                                            context: context,
                                            surahNumber: surahIndex + 1),
                                        trailing:
                                            Utils.displaySurahNamesArabicIcon(
                                                context: context,
                                                surahIndex: surahIndex),
                                        title: Text(
                                          "$surahName : $verseValue",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //  =========================== FUNCTIONS ===========================
  // start and end surahs and verses
  // this function display the start and end surahs and verses of each Juz
  Widget startAndEnd({required int juzIndex}) {
    Map<String, String> verseMapping =
        AppVariables.juzMetaData[juzIndex]["verse_mapping"];

    int startSurahIndex = int.parse(verseMapping.keys.first) - 1;
    int endSurahIndex = int.parse(verseMapping.keys.last) - 1;

    String startVerse = (verseMapping.values.first).split("-").first;
    String endVerse = (verseMapping.values.last).split("-").last;

    String startSurahName = context
        .read<SurahNamesBloc>()
        .state
        .surahNamesMetaData?[startSurahIndex]["name_complex"];

    String endSurahName = context
        .read<SurahNamesBloc>()
        .state
        .surahNamesMetaData?[endSurahIndex]["name_complex"];

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "start:",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            Text(
              "end:",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        SizedBox(width: 1.5.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$startSurahName : $startVerse",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "$endSurahName : $endVerse",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
