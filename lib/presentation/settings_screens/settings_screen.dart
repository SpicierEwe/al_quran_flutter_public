import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/arabic_settings_section_widget.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/data_update_settings_widget.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/theme_settings.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/translation_settings_section_widget.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/transliteration_settings_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:sizer/sizer.dart';

import '../../logic/language_bloc/language_bloc.dart';
import '../../logic/theme_bloc/theme_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    // get all the translation ids
    context.read<SettingsBloc>().add(SettingsEventGetAllTranslationIds(
        languageName: context
            .read<LanguageBloc>()
            .state
            .selectedLanguage["name"]
            .toString()));

    context.read<SettingsBloc>().add(SettingsEventGetAllReciters());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Color signatureColor = Color(0xff223C63);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return BlocBuilder<LanguageBloc, LanguageState>(
                    builder: (context, languageState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Column(
                              children: [
                                // ===============================
                                // section theme
                                // ===============================

                                SectionStyling(
                                    needBorder: false,
                                    themeState: themeState,
                                    sectionName: "Theme",
                                    needContentPadding: false,
                                    child: ThemeSettingsSectionWidget(
                                      settingsState: settingsState,
                                    )),

                                // ===============================
                                // section arabic
                                // ===============================

                                SectionStyling(
                                    needBorder: true,
                                    themeState: themeState,
                                    sectionName: "Arabic",
                                    child: ArabicSettingsSectionWidget(
                                      signatureColor: signatureColor,
                                      settingsState: settingsState,
                                    )),

                                // border

                                // ===============================
                                // section translation ===============
                                // ===============================

                                SectionStyling(
                                    themeState: themeState,
                                    sectionName:
                                        "Transliteration ( ${languageState.selectedLanguage["name"]} )",
                                    child: TransliterationSettingsSectionWidget(
                                      settingsState: settingsState,
                                    )),
                                // section translation

                                // ===============================
                                // section translation ===============
                                // ===============================

                                SectionStyling(
                                    themeState: themeState,
                                    sectionName:
                                        "Translation ( ${languageState.selectedLanguage["name"]} )",
                                    child: TranslationSettingsSectionWidget(
                                      settingsState: settingsState,
                                      signatureColor: signatureColor,
                                    )),

                                // ===============================
                                // section theme
                                // ===============================

                                SectionStyling(
                                    needBorder: true,
                                    themeState: themeState,
                                    sectionName: "Refresh Data",
                                    needContentPadding: false,
                                    child: const DataUpdateSettingsWidget()),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ));
  }
}

class SectionStyling extends StatelessWidget {
  const SectionStyling({
    super.key,
    this.needBorder = true,
    required this.themeState,
    required this.sectionName,
    this.needContentPadding = true,
    this.needTitlePadding = true,
    required this.child,
  });

  final ThemeState themeState;
  final String sectionName;
  final Widget child;
  final bool needBorder;
  final bool needContentPadding;
  final bool needTitlePadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (needBorder)
          Container(
            color: Theme.of(context).dividerColor.withOpacity(.1),
            height: 2.h,
          ),
        // Divider(
        //   thickness: .5.h,
        // ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            // color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 2.5.h),
          child: Column(
            children: [
              Container(
                padding: needTitlePadding
                    ? EdgeInsets.symmetric(horizontal: 5.w)
                    : null,
                child: Row(
                  children: [
                    Text(
                      sectionName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: needContentPadding
                    ? EdgeInsets.symmetric(horizontal: 5.w)
                    : null,
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
