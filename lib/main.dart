import 'dart:ffi';

import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/core/constants/strings.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/audio_bottom_bar_bloc/audio_bottom_bar_bloc.dart';
import 'package:al_quran_new/logic/audio_player_bloc/audio_player_bloc.dart';
import 'package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart';
import 'package:al_quran_new/logic/downloader_bloc/downloader_bloc.dart';
import 'package:al_quran_new/logic/juz_display_bloc/juz_display_bloc.dart';
import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:al_quran_new/logic/salah_bloc/salah_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:al_quran_new/logic/surah_info_bloc/surah_info_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:al_quran_new/logic/surah_tracker_bloc/surah_tracker_bloc.dart';
import 'package:al_quran_new/logic/theme_bloc/theme_bloc.dart';
import 'package:al_quran_new/presentation/router/app_router.dart';
import 'package:al_quran_new/presentation/widgets/audio_bottom_bar.dart';
import 'package:al_quran_new/presentation/widgets/bottom_donwnload_bar_widget.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import 'core/constants/enums.dart';
import 'logic/config_bloc/config_bloc.dart';
import 'logic/display_type_switcher_bloc/display_type_switcher_bloc.dart';
import 'logic/observer/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

// Get the application documents directory
  var path = await getApplicationDocumentsDirectory();

  // Initialize Hive with the obtained path
  Hive.init(path.path);

  // Open the Hive box
  await Hive.openBox('myBox');
  runApp(DevicePreview(
      isToolbarVisible: true,
      enabled: !kReleaseMode,
      builder: (BuildContext context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),
        BlocProvider<SurahNamesBloc>(
          create: (context) => SurahNamesBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(),
        ),
        BlocProvider<DownloaderBloc>(
          create: (context) => DownloaderBloc(
              languageBloc: context.read<LanguageBloc>(),
              settingsBloc: context.read<SettingsBloc>(),
              surahNamesBloc: context.read<SurahNamesBloc>()),
        ),
        BlocProvider<SurahDisplayBloc>(
          create: (context) => SurahDisplayBloc(),
        ),
        BlocProvider<ConfigBloc>(
          create: (context) => ConfigBloc(),
        ),
        BlocProvider<JuzDisplayBloc>(
          create: (context) => JuzDisplayBloc(),
        ),
        BlocProvider<SurahTrackerBloc>(
          create: (context) => SurahTrackerBloc(
              surahDisplayBloc: context.read<SurahDisplayBloc>(),
              juzDisplayBloc: context.read<JuzDisplayBloc>()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<DisplayTypeSwitcherBloc>(
          create: (context) => DisplayTypeSwitcherBloc(
              surahDisplayBloc: context.read<SurahDisplayBloc>(),
              surahTrackerBloc: context.read<SurahTrackerBloc>()),
        ),
        BlocProvider<AudioPlayerBloc>(
          create: (context) => AudioPlayerBloc(
              juzDisplayBloc: context.read<JuzDisplayBloc>(),
              settingsBloc: context.read<SettingsBloc>(),
              surahNamesBloc: context.read<SurahNamesBloc>(),
              displayTypeSwitcherBloc: context.read<DisplayTypeSwitcherBloc>(),
              surahDisplayBloc: context.read<SurahDisplayBloc>()),
        ),
        BlocProvider<AudioBottomBarBloc>(
          create: (context) => AudioBottomBarBloc(
              audioPlayerBloc: context.read<AudioPlayerBloc>()),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(
            displayTypeSwitcherBloc: context.read<DisplayTypeSwitcherBloc>(),
            juzDisplayBloc: context.read<JuzDisplayBloc>(),
            surahDisplayBloc: context.read<SurahDisplayBloc>(),
          ),
        ),
        BlocProvider<PermissionsBloc>(
          create: (context) => PermissionsBloc(),
        ),
        BlocProvider<SalahBloc>(
          create: (context) =>
              SalahBloc(permissionBloc: context.read<PermissionsBloc>()),
        ),
        BlocProvider<SurahInfoBloc>(
          create: (context) => SurahInfoBloc(
            languageBloc: context.read<LanguageBloc>(),
          ),
        ),
      ],
      child: Sizer(
          builder: (context, orientation, deviceType) =>
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return MaterialApp.router(
                    builder: (context, child) => Scaffold(
                      body: AudioBottomBarWidget(
                        child: child!,
                      ),

                      // Download progress display bottom bar
                      bottomNavigationBar: const BottomDownloadBarWidget(),
                    ),
                    routerConfig: AppRouter.router,
                    title: AppStrings.appName,
                    debugShowCheckedModeBanner: false,
                    theme: themeState.themeData,
                  );
                },
              )),
    );
  }
}
