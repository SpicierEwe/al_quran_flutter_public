import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/custom_themes.dart';
import '../../../core/constants/variables.dart';
import '../../../logic/settings_bloc/settings_bloc.dart';

class ArabicSettingsSectionWidget extends StatefulWidget {
  final Color signatureColor;
  final SettingsState settingsState;

  const ArabicSettingsSectionWidget(
      {super.key, required this.signatureColor, required this.settingsState});

  @override
  State<ArabicSettingsSectionWidget> createState() =>
      _ArabicSettingsSectionWidgetState();
}

class _ArabicSettingsSectionWidgetState
    extends State<ArabicSettingsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    // selectedArabicFontIndex is the index of the selected font
    final selectedArabicFontIndex = context
        .select((SettingsBloc bloc) => bloc.state.selectedQuranScriptIndex);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            children: [
              Text(
                'Quran Script',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        FlutterToggleTab(
          width: 18.w,
          // width in percent
          borderRadius: 50,

          height: 51,
          marginSelected: const EdgeInsets.all(5),

          selectedIndex: selectedArabicFontIndex,
          selectedBackgroundColors: [widget.signatureColor],
          unSelectedBackgroundColors: const [Colors.white38],

          selectedTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.white,
              ),
          unSelectedTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
              ),
          labels: AppVariables.arabicScriptNames,
          selectedLabelIndex: (index) {
            // update the tab bar with the selected index
            context.read<SettingsBloc>().add(SettingsEventChangeQuranFont(
                index: index, fontName: AppVariables.arabicScriptNames[index]));
          },
          isScroll: false,
        ),
        Utils.customSpacer(),

        // ================== font changer ===========================
        fontSizeChanger(
          context: context,
          settingsState: widget.settingsState,
          fontIncreaseOnPressed: () {
            context
                .read<SettingsBloc>()
                .add(UpdateQuranTextFontSizeEvent(shouldIncrease: true));
          },
          fontDecreaseOnPressed: () {
            context
                .read<SettingsBloc>()
                .add(UpdateQuranTextFontSizeEvent(shouldIncrease: false));
          },
          wordsData:
              LocalDataRepository.getStoredQuranArabicChapter(chapterId: 1)
                  ?.first["words"],
        ),

        // ================== change reciter ===========================

        Utils.customSpacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Reciter",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade50,
                      backgroundImage: widget
                                  .settingsState.selectedReciterId.isNotEmpty &&
                              widget.settingsState.allRecitersList.isNotEmpty
                          ? AssetImage(
                              "assets/images/${widget.settingsState.selectedReciterId.contains("translation") ? "translators" : "reciters"}/${widget.settingsState.allRecitersList.isNotEmpty ? widget.settingsState.allRecitersList.where((element) => element["id"].toString() == widget.settingsState.selectedReciterId).first[widget.settingsState.selectedReciterId.contains("translation") ? "translator_name" : "reciter_name"].toString().replaceAll(" ", "_") : ""}.png",
                            )
                          : const AssetImage("assets/images/unknown.png"),
                    ),
                    title: Text(
                      widget.settingsState.allRecitersList.isNotEmpty
                          ? widget.settingsState.allRecitersList
                              .where((element) =>
                                  element["id"].toString() ==
                                  widget.settingsState.selectedReciterId)
                              .first[widget.settingsState.selectedReciterId
                                      .contains("translation")
                                  ? "translator_name"
                                  : "reciter_name"]
                              .toString()
                          : "",
                      // style: Theme.of(context)
                      //     .textTheme
                      //     .titleSmall,
                      textAlign: TextAlign.center,
                      // overflow:
                      //     TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () {
                    context.push('/change_reciter_settings');
                  }),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // ===========================================================================
  // ===========================================================================
  //
  //                 Supporting function for the above build method
  //
  // ===========================================================================
  // ===========================================================================
  // ===========================================================================
  Column fontSizeChanger(
      {required BuildContext context,
      required SettingsState settingsState,
      required void Function() fontIncreaseOnPressed,
      required void Function() fontDecreaseOnPressed,
      required dynamic wordsData}) {
    // [widget.settingsState.selectedQuranFontName == "uthmani"
    //     ? "qpc_uthmani_hafs"
    //     : "text_qpc_nastaleeq"]
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Font Size",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: fontDecreaseOnPressed,
                    child: Text(
                      "-",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 21.sp,
                          ),
                      textAlign: TextAlign.center,
                      // overflow:
                      //     TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    settingsState.quranTextFontSize.truncate().toString(),

                    // style: Theme.of(context)
                    //     .textTheme
                    //     .titleSmall,
                    textAlign: TextAlign.center,
                    // overflow:
                    //     TextOverflow.ellipsis,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      shape: const CircleBorder(),
                    ),
                    onPressed: fontIncreaseOnPressed,
                    child: Text(
                      "+",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      // overflow:
                      //     TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // =============================================
        // FONT WORD Spacing =============================================
        // =============================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Word Spacing",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () => context.read<SettingsBloc>().add(
                        UpdateQuranTextWordSpacingEvent(shouldIncrease: false)),
                    child: Text(
                      "-",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 21.sp,
                          ),
                      textAlign: TextAlign.center,
                      // overflow:
                      //     TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    settingsState.quranTextWordSpacing == 0
                        ? "auto"
                        : settingsState.quranTextWordSpacing
                            .truncate()
                            .toString(),
                    // style: Theme.of(context)
                    //     .textTheme
                    //     .titleSmall,
                    textAlign: TextAlign.center,
                    // overflow:
                    //     TextOverflow.ellipsis,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () => context.read<SettingsBloc>().add(
                        UpdateQuranTextWordSpacingEvent(shouldIncrease: true)),
                    child: Text(
                      "+",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      // overflow:
                      //     TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.1.h),
          margin: EdgeInsets.symmetric(vertical: 2.h),
          width: 100.w,
          // color: const Color(0xfff8f9fa),
          color: CustomThemes.settingsVerseContainerColor(context: context),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: settingsState.selectedQuranScriptType
                          .toString()
                          .toLowerCase() ==
                      "indopak"
                  ? settingsState.quranTextWordSpacing.w + 2.5.w
                  : settingsState.quranTextWordSpacing.w,
              children: [
                // ========================
                // arabic verse
                // ========================
                for (int i = 0; i < wordsData.length; i++)
                  // if tajweed then display images
                  (settingsState.selectedQuranScriptType == "tajweed")
                      ? Utils.displayTajweedWordImages(
                          context: context,
                          wordIndex: i,
                          verseIndex: 0,
                          surahId: 1,
                          settingsState: settingsState,
                          wordsLength: wordsData.length)
                      : Text(
                          wordsData[i][Utils.quranScriptName(
                                  quranScriptName:
                                      settingsState.selectedQuranScriptType)]
                              .toString(),
                          style: TextStyle(
                            fontFamily:
                                "${settingsState.selectedQuranScriptType}_font",
                            fontSize: settingsState.quranTextFontSize.sp,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
              ],
            ),
          ),
        ),

        // =============================================
        // if the selected quran script is tajweed then display the warning
        if (settingsState.selectedQuranScriptType == "tajweed")
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "* for Tajweed, Internet is required. \n Might see some performance issue in older phones.",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.red),
                ),
              ),
              Utils.customSpacer(),
              const Text("Tajweed Rules :"),
              Utils.customSpacer(
                height: 1,
              ),

              // TAJWEED RULES
              Container(
                // color: const Color(0xfff8f9fa),
                child: Column(
                  children: [
                    for (int i = 0; i < AppVariables.tajweedRules.length; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 1.h,
                        ),
                        child: Row(
                          children: [
                            ColorFiltered(
                              colorFilter: CustomThemes.tajweedColorInverter(
                                  context: context),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppVariables.tajweedRules[i]["color"],
                                ),
                              ),
                            ),
                            Utils.customSpacer(
                              width: 3,
                            ),
                            Text(
                              AppVariables.tajweedRules[i]["rule"].toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
      ],
    );
  }
}
