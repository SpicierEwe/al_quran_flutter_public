import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';

import '../../logic/language_bloc/language_bloc.dart';
import '../../logic/settings_bloc/settings_bloc.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> tabs = [
      "Download Status",
      "Permissions Status",
      "Languages Data",
      "Translation Ids",
      "Surah Names",
      "Surah Data",
      "Surah Translation"
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Developer Screen"),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/settings');
              },
              icon: Icon(Icons.settings_rounded),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              for (var tab in tabs)
                Tab(
                  text: tab,
                ),
            ],
          ),
        ),
        body: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, languageState) {
            return BlocBuilder<PermissionsBloc, PermissionsState>(
              builder: (context, permissionsState) {
                return BlocBuilder<DownloaderBloc, DownloaderState>(
                  builder: (context, downloaderState) {
                    return BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return BlocBuilder<SurahNamesBloc, SurahNamesState>(
                          builder: (context, surahNamesState) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TabBarView(
                                children: [
                                  // 1st tabview
                                  Column(
                                    children: [
                                      Text(
                                        "ïs ERROR = ${downloaderState.isError}",
                                      ),
                                      Text(
                                        "is Surah names Metadata = ${downloaderState.isSurahNamesMetaDataDownloaded}",
                                      ),
                                      Text(
                                        "is quran downloaded = ${downloaderState.isQuranDownloaded}",
                                      ),
                                      Text(
                                        "are translation ids downloaded = ${downloaderState.areTranslationIdsDownloaded}",
                                      ),
                                      Text(
                                        "is translation downloaded = ${downloaderState.isTranslationDownloaded}",
                                      ),
                                      Text(
                                          "is All Data downloaded = ${downloaderState.isAllDataDownloaded}"),
                                    ],
                                  ),
                                  // permissions
                                  Column(
                                    children: [
                                      Text(
                                        "location permission  = ${permissionsState.isLocationPermissionGranted}",
                                      ),
                                      // Text(
                                      //   "location Data  = ${permissionsState.locationData.toString()}",
                                      // ),
                                    ],
                                  ),

                                  // all languages data
                                  ListView(
                                    children: [
                                      Text(
                                        languageState.allLanguages.toString(),
                                      ),
                                      // Text(
                                      //   "location Data  = ${permissionsState.locationData.toString()}",
                                      // ),
                                    ],
                                  ),
                                  // translation ids
                                  Column(
                                    children: [
                                      Text(
                                        settingsState.translationIds.toString(),
                                      ),
                                      // Text(
                                      //   "location Data  = ${permissionsState.locationData.toString()}",
                                      // ),
                                    ],
                                  ),

                                  ListView(
                                    children: [
                                      Text(surahNamesState
                                          .surahNamesMetaData![0]
                                          .toString()),
                                    ],
                                  ),
                                  ListView(
                                    children: [
                                      Text(LocalDataRepository
                                              .getStoredQuranArabicChapter(
                                                  chapterId: 1)
                                          .toString()),
                                    ],
                                  ),
                                  ListView(
                                    children: [
                                      Text(LocalDataRepository
                                              .getStoredQuranChapterTranslation(
                                                  translationId: settingsState
                                                      .selectedTranslationId,
                                                  chapterId: 1)
                                          .toString()),
                                    ],
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
          },
        ),
      ),
    );
  }
}
