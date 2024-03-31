import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../logic/surah_info_bloc/surah_info_bloc.dart';

class SurahInfoDisplayScreen extends StatefulWidget {
  final int surahId;

  const SurahInfoDisplayScreen({super.key, required this.surahId});

  @override
  State<SurahInfoDisplayScreen> createState() => _SurahInfoDisplayScreenState();
}

class _SurahInfoDisplayScreenState extends State<SurahInfoDisplayScreen> {
  @override
  void initState() {
    super.initState();

    context.read<SurahInfoBloc>().add(GetSurahInfo(
          surahId: widget.surahId,
          languageCode:
              context.read<LanguageBloc>().state.selectedLanguage["iso_code"],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final int surahIndex = widget.surahId - 1;
    final List<dynamic> surahNamesMetaData =
        context.read<SurahNamesBloc>().state.surahNamesMetaData!;
    final String surahNameTransliteration =
        surahNamesMetaData[surahIndex]["name_complex"].toString();
    final String surahNameMeaning =
        surahNamesMetaData[surahIndex]["translated_name"]["name"].toString();

    final String revelationPlace =
        surahNamesMetaData[surahIndex]["revelation_place"].toString();

    final String verseCount =
        surahNamesMetaData[surahIndex]["verses_count"].toString();

    final revelationOrder =
        surahNamesMetaData[surahIndex]["revelation_order"].toString();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "about   ",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 11.sp,
                      )),
              TextSpan(
                text: context
                    .read<SurahNamesBloc>()
                    .state
                    .surahNamesMetaData![surahIndex]["name_complex"]
                    .toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    " - ${context.read<SurahNamesBloc>().state.surahNamesMetaData![surahIndex]["name_arabic"].toString()}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<SurahInfoBloc, SurahInfoState>(
        builder: (context, state) {
          if (state.isError) {
            // if error show error message
            return const Center(
              child: Text("Error"),
            );
          }

          // if data available show the data
          if (state.surahInfo != null) {
            final surahInfoData = state.surahInfo!;
            return ListView(
              children: [
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5.w, right: 3.w),
                      padding: EdgeInsets.only(right: 3.w),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.teal,
                            width: .5.w,
                          ),
                        ),
                      ),
                      // surah name in arabic
                      child: Column(
                        children: [
                          Utils.displaySurahNamesArabicIcon(
                              useNewSurahFont: true,
                              fontSize: 19.sp,
                              surahIndex: widget.surahId - 1,
                              context: context),
                          Text(revelationPlace.toString(),
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            "$verseCount ayahs",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // surah name translation
                        Text(
                          surahNameTransliteration,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          surahNameMeaning,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "revelation order: $revelationOrder",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),

                // body
                Directionality(
                  textDirection:
                      Utils.translationTextDirection(context: context),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(1.w, 2.h, 1.w, 1.h),
                    child: Column(
                      children: [
                        Html(
                          data:
                              "<h3>Source</h3> <em>${surahInfoData["source"]}</em>",
                        ),
                        Html(
                          data:
                              "<h3>Summary</h3> ${surahInfoData["short_text"]}",
                        ),
                        Html(
                          data: surahInfoData["text"].toString(),
                          style: {
                            "p,h2": Style(
                                lineHeight: LineHeight.number(
                                    Utils.translationFontsLineHeights(
                                        context: context)),
                                fontFamily:
                                    Utils.translationFonts(context: context)),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // if data is not available show loading
          return const Center(
            child: LoadingWidget(),
          );
        },
      ),
    );
  }
}
