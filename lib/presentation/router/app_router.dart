import 'package:al_quran_new/presentation/developer_screens/developer_screen.dart';
import 'package:al_quran_new/presentation/favourites_screen/favourites_screen.dart';
import 'package:al_quran_new/presentation/home_screen/home_screen.dart';
import 'package:al_quran_new/presentation/intital_screens/choose_language.dart';
import 'package:al_quran_new/presentation/intital_screens/welcome_screen.dart';
import 'package:al_quran_new/presentation/juz_display_screen/juz_display_screen.dart';
import 'package:al_quran_new/presentation/more_section/allah_names_display_screen.dart';
import 'package:al_quran_new/presentation/more_section/rabbana_duas_display_screen.dart';
import 'package:al_quran_new/presentation/more_section/rasool_allah^_names_display_screen.dart';
import 'package:al_quran_new/presentation/more_section/salah_times_display_screen/salah_times_display_screen.dart';
import 'package:al_quran_new/presentation/settings_screens/settings_screen.dart';
import 'package:al_quran_new/presentation/settings_screens/widgets/change_reciter_settings_sub_screen.dart';
import 'package:al_quran_new/presentation/surah_display_screen/surah_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/config_bloc/config_bloc.dart';

class AppRouter {
  /// The route configuration.
  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          /*
          * If the user has not seen the welcome screen, show the welcome screen
          * */
          if (!context.read<ConfigBloc>().state.hasSeenWelcomeScreen) {
            return const WelcomeScreen();
          }

          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'welcome',
            builder: (BuildContext context, GoRouterState state) {
              return const WelcomeScreen();
            },
          ),
          GoRoute(
              path: "choose_language",
              builder: (BuildContext context, GoRouterState state) =>
                  const ChooseLanguage()),
          GoRoute(
              path: "change_language",
              builder: (BuildContext context, GoRouterState state) =>
                  const ChooseLanguage(
                    isChangingManuallyFromSettings: true,
                  )),
          GoRoute(
              path: "settings",
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen()),
          GoRoute(
              path: "surah_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const SurahDisplayScreen()),
          GoRoute(
              path: "settings",
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen()),
          GoRoute(
              path: "change_reciter_settings",
              builder: (BuildContext context, GoRouterState state) =>
                  const ChangeReciterSettingsSubScreen()),
          GoRoute(
              path: "juz_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const JuzDisplayScreen()),
          GoRoute(
              path: "developer_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const DeveloperScreen()),
          GoRoute(
              path: "favourites_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const FavouritesScreen()),
          GoRoute(
              path: "salah_times_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const SalahTimesDisplayScreen()),
          GoRoute(
              path: "allah_names_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const AllahNamesDisplayScreen()),
          GoRoute(
              path: "rasool_allah_names_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const RasoolAllahNamesDisplayScreen()),
          GoRoute(
              path: "rabbana_duas_display_screen",
              builder: (BuildContext context, GoRouterState state) =>
                  const RabbanaDuasDisplayScreen()),
        ],
      ),
    ],
  );

  static get router => _router;
}
