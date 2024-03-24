import 'package:al_quran_new/core/constants/strings.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/core/widgets/loading_widget.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';
import 'package:flag/flag.dart';

import '../../logic/config_bloc/config_bloc.dart';
import '../../logic/language_bloc/language_bloc.dart';

class ChooseLanguage extends StatefulWidget {
  final bool isChangingManuallyFromSettings;

  const ChooseLanguage(
      {super.key, this.isChangingManuallyFromSettings = false});

  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  late Map<String, dynamic> _selectedLanguage;

  @override
  void initState() {
    // default SELECTED LANGUAGE initializing...
    _selectedLanguage = context.read<LanguageBloc>().state.selectedLanguage;

    super.initState();
    context.read<LanguageBloc>().add(FetchAvailableLanguagesEvent());
  }

  // FORMAT LANGUAGE NAME if native name is not available then use name instead
  String formatName({required Map<String, dynamic> languageData}) {
    if (languageData["native_name"] != "") {
      return languageData["native_name"];
    } else {
      return languageData["name"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // NEXT BUTTON
        floatingActionButton: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return Visibility(
              visible: !state.isError,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    extendedPadding: EdgeInsets.symmetric(horizontal: 10.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // floating action button click
                    onPressed: () {
                      // updating selected language from bloc
                      context.read<LanguageBloc>().add(SelectedLanguageEvent(
                          selectedLanguage: _selectedLanguage));
                      // if changing from settings screen
                      /*
                      * Means the user is changing the language from settings screen
                      * */
                      if (widget.isChangingManuallyFromSettings) {
                        context.pop();
                        context.read<DownloaderBloc>().add(DownloadQuranEvent(
                              isOnlyLanguageChange: true,
                            ));
                      }
                      // if language selected form welcome screen

                      else {
                        context
                            .read<ConfigBloc>()
                            .add(SeenInitialScreensEventPassed());

                        context.go('/');
                      }
                    },
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            widget.isChangingManuallyFromSettings
                                ? "Confirm"
                                : "Next",
                            style: TextStyle(
                              fontSize: AppVariables.buttonTextMedium,
                            )),
                        SizedBox(
                          width: 3.w,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10.sp,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Text(
                AppStrings.chooseLanguageScreenTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(AppStrings.chooseLanguageScreenSubtitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                      )),

              SizedBox(
                height: 2.h,
              ),

              // GRID VIEW OF LANGUAGES
              Expanded(
                child: BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    final allLanguages = state.searchQuery.isNotEmpty
                        ? state.searchResults
                        : state.allLanguages;

                    // IF LANGUAGES ARE NOT DOWNLOADED=================
                    if (state.isError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Failed to load languages",
                              style: Theme.of(context).textTheme.titleSmall),
                          SizedBox(
                            height: 2.h,
                          ),
                          Center(
                            child: SizedBox(
                              width: 30.w,
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<LanguageBloc>()
                                      .add(RetryLanguagesDownloadEvent());
                                },
                                child: const Center(child: Text("Retry")),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (allLanguages == null) {
                      return const LoadingWidget();
                    }

                    return Column(
                      children: [
                        // SEARCH BAR ==================,
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 7.w,
                          ),
                          height: 40, // Adjust the height as needed
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                              ),
                              hintText: "Search languages...",
                              hintStyle: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onChanged: (value) {
                              // print(value);
                              context
                                  .read<LanguageBloc>()
                                  .add(SearchLanguageEvent(searchQuery: value));
                            },
                          ),
                        ),

                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 5.h),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 1.5),
                            itemCount: allLanguages.length,
                            itemBuilder: (context, index) {
                              // LANGUAGE NAME ex: English, Urdu
                              String languageName =
                                  formatName(languageData: allLanguages[index]);
                              // LANGUAGE iso code ex: en, ur
                              String languageIsoCode =
                                  allLanguages[index]["iso_code"];

                              bool isSelected = _selectedLanguage["iso_code"] ==
                                  languageIsoCode;
                              return BlocBuilder<LanguageBloc, LanguageState>(
                                builder: (context, state) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 1.h),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? Theme.of(context).primaryColor
                                              // ? AppVariables.companyColor
                                              //     .withOpacity(.85)
                                              : null,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                  color: isSelected
                                                      ? AppVariables
                                                          .companyColor
                                                      : Colors.grey.shade300)),
                                        ),

                                        // ON PRESS OF LANGUAGE BUTTON
                                        onPressed: () {
                                          // context.read<LanguageBloc>().add(
                                          //     SelectedLanguageEvent(
                                          //         selectedLanguage:
                                          //             allLanguages[index]));
                                          setState(() {
                                            _selectedLanguage =
                                                allLanguages[index];
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // FLAGS IMAGE

                                            Flag.flagsCode
                                                    .contains(languageIsoCode)
                                                ? Flag.fromString(
                                                    languageIsoCode,
                                                    height: 45,
                                                    width: 45,
                                                    fit: BoxFit.cover,
                                                    borderRadius: 50,
                                                  )
                                                : Container(
                                                    height: 45,
                                                    width: 45,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "assets/flags/$languageIsoCode.jpg"),
                                                            fit: BoxFit.cover,
                                                            alignment: Alignment
                                                                .center),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                  ),

                                            SizedBox(
                                              height: 1.5.h,
                                            ),
                                            // LANGUAGE NAME =====
                                            Text(languageName,
                                                style: state.selectedLanguage[
                                                            "iso_code"] ==
                                                        languageIsoCode
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                            color: Colors.white)
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .titleSmall),
                                          ],
                                        )),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
