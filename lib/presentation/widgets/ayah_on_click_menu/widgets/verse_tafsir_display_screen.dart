import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sizer/sizer.dart';

import '../../../../logic/tafsir_bloc/tafsir_bloc.dart';

class VerseTafsirDisplayScreen extends StatefulWidget {
  final int surahId;
  final int verseId;

  const VerseTafsirDisplayScreen({
    super.key,
    required this.surahId,
    required this.verseId,
  });

  @override
  State<VerseTafsirDisplayScreen> createState() =>
      _VerseScreenDisplayScreenState();
}

class _VerseScreenDisplayScreenState extends State<VerseTafsirDisplayScreen> {
  @override
  void initState() {
    super.initState();

    {
      context.read<TafsirBloc>().add(GetAllTafsirsMetaData(
          surahId: widget.surahId, verseId: widget.verseId));
    }
  }

  void updateLocalSelectedTafsirId({required int newSelectedTafsirId}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<SurahTrackerBloc, SurahTrackerState>(
          builder: (context, surahTrackerState) {
            return BlocBuilder<TafsirBloc, TafsirState>(
              builder: (context, tafsirState) {
                if (tafsirState.languageSpecificTafsirIdsMetaData == null ||
                    tafsirState.tafsirData == null ||
                    tafsirState.allTafsirIdsMetaData == null) {
                  return const LoadingWidget();
                }
                if (tafsirState.isError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Oops.."),
                        const Text("Something went wrong!"),
                        //    retry button

                        SizedBox(height: 2.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            // refetch tafsir entire data again
                            context.read<TafsirBloc>().add(
                                GetAllTafsirsMetaData(
                                    surahId: widget.surahId,
                                    verseId: widget.verseId));
                          },
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Verse Tafsir'),
                  ),

                  // Bottom navigation bar
                  bottomNavigationBar: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.w,
                      vertical: 1.h,
                    ),
                    child: DropdownButtonFormField<int>(

                        // Use DropdownButtonFormField for validation etc.
                        value: tafsirState.languageSpecificTafsirIdsMetaData!
                            .first['id'], // Must be of int type
                        decoration: InputDecoration(
                          // Add decoration for custom styling
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        items: tafsirState.languageSpecificTafsirIdsMetaData!
                            .map<DropdownMenuItem<int>>((value) {
                          return DropdownMenuItem(
                            value: value['id'] as int, // Must be of int type
                            // Cast to int explicitly if needed
                            child: Text(
                              value['name'],
                              textAlign: TextAlign.center,
                              // style: TextStyle(
                              //   // Customize text style (optional)
                              //   fontSize: 16.0,
                              //   color: Colors.grey.shade800,
                              // ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() {
                              context.read<TafsirBloc>().add(GetTafsirEvent(
                                  tafsirId: val!,
                                  surahId: widget.surahId,
                                  verseId: widget.verseId));
                            })),
                  ), // Update state

                  body: BlocBuilder<TafsirBloc, TafsirState>(
                    builder: (context, state) {
                      if (state.isError) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[Text("Error")],
                          ),
                        );
                      }
                      if (state.languageSpecificTafsirIdsMetaData == null ||
                          state.languageSpecificTafsirIdsMetaData!.isEmpty ||
                          state.tafsirData == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Check if the text direction is right to left
                      bool isRightToLeft =
                          Utils.translationTextDirection(context: context) ==
                              TextDirection.rtl;
                      return ListView(
                        children: <Widget>[
                          Utils.surahTopInfo(
                            context: context,
                            surahIndex: widget.surahId - 1,
                          ),
                          SizedBox(height: 5.h),
                          // display single verse with translation

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.w,
                            ),
                            child: Utils.displaySingleVerseWithTranslation(
                              settingsState: settingsState,
                              verseIndex: widget.verseId - 1,
                              context: context,
                              surahTrackerState: surahTrackerState,
                              surahIndex: widget.surahId - 1,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Chip(
                              label: Text(
                                  "Surah ${widget.surahId} : ${widget.verseId}")),

                          SizedBox(height: 3.h),
                          Html(
                              data: state.tafsirData!["text"].toString(),
                              style: {
                                "p": Style(
                                  direction: Utils.translationTextDirection(
                                      context: context),
                                  fontFamily:
                                      Utils.translationFonts(context: context),
                                  lineHeight: LineHeight(
                                    isRightToLeft
                                        ? Utils.translationFontsLineHeights(
                                                context: context) +
                                            .5.sp
                                        : 0,
                                  ),
                                  fontSize: isRightToLeft
                                      ? FontSize(
                                          settingsState.translationFontSize +
                                              3.sp,
                                        )
                                      : FontSize(
                                          settingsState.translationFontSize +
                                              1.5.sp,
                                        ),
                                ),
                              }),
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
