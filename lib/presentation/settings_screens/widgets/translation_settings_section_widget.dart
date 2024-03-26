import 'dart:async';

import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import "../../../core/utils/utils.dart";

import '../../../core/widgets/loading_widget.dart';
import '../../../logic/downloader_bloc/downloader_bloc.dart';
import '../../../logic/repositories/local_data_repository.dart';
import '../../../logic/settings_bloc/settings_bloc.dart';

class TranslationSettingsSectionWidget extends StatefulWidget {
  final Color signatureColor;
  final SettingsState settingsState;

  const TranslationSettingsSectionWidget(
      {super.key, required this.signatureColor, required this.settingsState});

  @override
  State<TranslationSettingsSectionWidget> createState() =>
      _TranslationSettingsSectionWidgetState();
}

class _TranslationSettingsSectionWidgetState
    extends State<TranslationSettingsSectionWidget> {




  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = widget.settingsState;
    String translationName = (settingsState.translationIds?.firstWhere(
        (element) => element["id"] == settingsState.selectedTranslationId,
        orElse: () => {"name": "Loading.."})["name"]);

    String displayText() {

     return LocalDataRepository.getStoredQuranChapterTranslation(
        chapterId: 1,
        translationId: settingsState.selectedTranslationId,
      )!
          .first["text"];
    }


    return Column(
      children: [
        // ===============================
        // Translator -----
        // ===============================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Translation",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // translator name
                child: Text(
                  (translationName),
                  textAlign: TextAlign.center,
                ),
                onPressed: () => showMoreTranslationsBottomModalSheet(
                    settingsState: settingsState),
              ),
            ),
          ],
        ),
        Utils.customSpacer(),

        // ===============================
        //  Font Size -----
        // ===============================
        fontSizeChangerWidget(
          context: context,
          settingsState: settingsState,
          displayText: displayText(),



          // LocalDataRepository.getStoredQuranChapterTranslation(
          //   chapterId: 1,
          //   translationId: settingsState.selectedTranslationId,
          // )!
          //     .first["text"],
          fontDecreaseOnPressed: () {
            context
                .read<SettingsBloc>()
                .add(UpdateTranslationFontSizeEvent(shouldIncrease: false));
          },
          fontIncreaseOnPressed: () {
            context
                .read<SettingsBloc>()
                .add(UpdateTranslationFontSizeEvent(shouldIncrease: true));
          },
        ),
        // ===============================
        // Change Language -----
        // ===============================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Change Language",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    context.read<LanguageBloc>().state.selectedLanguage["name"],
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => context.push("/change_language")),
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

  Column fontSizeChangerWidget(
      {required BuildContext context,
      required SettingsState settingsState,
      required void Function() fontIncreaseOnPressed,
      required void Function() fontDecreaseOnPressed,
      required String displayText}) {
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
                    ),
                  ),
                  Text(
                    settingsState.translationFontSize.truncate().toString(),
                    textAlign: TextAlign.center,
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          margin: EdgeInsets.symmetric(vertical: 2.h),
          color: CustomThemes.settingsVerseContainerColor(context: context),
          child: Html(
            data: displayText.toString(),

            style: {
              "body": Style(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
                fontSize: FontSize(settingsState.translationFontSize.sp),
                fontFamily: Utils.translationFonts(context: context ),
              ),
            },
            // overflow:
            //     TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  showMoreTranslationsBottomModalSheet({required SettingsState settingsState}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<DownloaderBloc, DownloaderState>(
          builder: (context, modalDownloaderState) {
            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, modalSettingsState) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    if (modalSettingsState.translationIds == null) {
                      return const LoadingWidget();
                    }
                    return SizedBox(
                      height: 60.h,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: const Text("Select Translation"),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  modalSettingsState.translationIds!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  color: settingsState.selectedTranslationId ==
                                          modalSettingsState
                                              .translationIds![index]["id"]
                                      ? widget.signatureColor
                                      : null,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            modalSettingsState
                                                .translationIds![index]["name"],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: settingsState
                                                                .selectedTranslationId ==
                                                            modalSettingsState
                                                                    .translationIds![
                                                                index]["id"]
                                                        ? Colors.white
                                                        : null),
                                          ),
                                          // translator author
                                          subtitle: Text(
                                              modalSettingsState
                                                      .translationIds![index]
                                                  ["author_name"],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: settingsState
                                                                .selectedTranslationId ==
                                                            modalSettingsState
                                                                    .translationIds![
                                                                index]["id"]
                                                        ? Colors.white
                                                        : null,
                                                  )),
                                          onTap: () {
                                            if (modalDownloaderState
                                                .downloadedTranslationIds
                                                .contains(modalSettingsState
                                                        .translationIds![index]
                                                    ["id"])) {
                                              Navigator.pop(context);
                                              context.read<SettingsBloc>().add(
                                                  SettingsEventChangeTranslation(
                                                      translationId:
                                                          modalSettingsState
                                                                  .translationIds![
                                                              index]["id"]));
                                            }
                                          },
                                        ),
                                      ),
                                      if (!modalDownloaderState
                                              .downloadedTranslationIds
                                              .contains(modalSettingsState
                                                      .translationIds![index]
                                                  ["id"]) &&
                                          modalDownloaderState
                                                  .additionalDownloadingId !=
                                              modalSettingsState
                                                  .translationIds![index]["id"])
                                        IconButton(
                                            onPressed: () {
                                              context.read<DownloaderBloc>().add(
                                                  DownloadAdditionalTranslationEvent(
                                                      translationId:
                                                          modalSettingsState
                                                              .translationIds![
                                                                  index]["id"]
                                                              .toString(),
                                                      context: context));
                                            },
                                            icon: Icon(
                                              Icons.download,
                                              color: settingsState
                                                          .selectedTranslationId ==
                                                      modalSettingsState
                                                              .translationIds![
                                                          index]["id"]
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.grey.shade300),
                                              elevation:
                                                  MaterialStateProperty.all(3),
                                            )),
                                      if (modalDownloaderState
                                              .additionalDownloadingId ==
                                          modalSettingsState
                                              .translationIds![index]["id"])
                                        Container(
                                          margin: EdgeInsets.only(right: 5.w),
                                          width: 15,
                                          height: 15,
                                          child:
                                              const CircularProgressIndicator(),
                                        )
                                    ],
                                  ),
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
          },
        );
      },
    );
  }
}
