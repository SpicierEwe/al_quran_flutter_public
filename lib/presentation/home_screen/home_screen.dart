import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/strings.dart';
import 'package:al_quran_new/logic/bookmark_bloc/bookmark_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:al_quran_new/presentation/home_screen/widgets/juz_names_widget.dart';
import 'package:al_quran_new/presentation/home_screen/widgets/more_display_widget.dart';
import 'package:al_quran_new/presentation/home_screen/widgets/surah_names_widget.dart';
import 'package:al_quran_new/presentation/surah_display_screen/surah_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import '../../logic/config_bloc/config_bloc.dart';
import '../../logic/downloader_bloc/downloader_bloc.dart';
import '../../logic/language_bloc/language_bloc.dart';
import '../../logic/surah_names_bloc/surah_names_bloc.dart';

/*
* Home screen is responsible to decide which type of screen should be displayed.
* it works as a type of a router which routes to the appropriate screens
* it will be responsible to either display the initial screens ( welcome , language screens etc) ot the actual app screens
*/

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('myBox');

  @override
  void initState() {
    super.initState();

    /*
    * this is when the app runs for the 1st time where error and isAllDataDownloaded will
    * be false */
    // if (context.read<DownloaderBloc>().state.isAllDataDownloaded == false &&
    //     context.read<DownloaderBloc>().state.isError == false) {
    //   print("============ DOWNLOADING ENTIRE DATA =================");
    //   context.read<DownloaderBloc>().add(DownloadQuranEvent());
    // } else {
    //   print("============ RETRY EVENT ENTIRE DATA =================");
    //   context.read<DownloaderBloc>().add(RetryDownloadEvent());
    // }
    //  if there is error in downloading the data this will allow us to retry
    // else if (context.read<DownloaderBloc>().state.isError == true) {
    //   context.read<DownloaderBloc>().add(RetryDownloadEvent());
    // }

    // print("============ DOWNLOADING ENTIRE DATA =================");

    if (context.read<DownloaderBloc>().state.isAllDataDownloaded == false &&
        context.read<DownloaderBloc>().state.isError == false) {
      print("============ DOWNLOADING ENTIRE DATA =================");
      context.read<DownloaderBloc>().add(DownloadQuranEvent());
    }
    if (context.read<DownloaderBloc>().state.isError == true) {
      print("============ RETRY EVENT ENTIRE DATA =================");
      context.read<DownloaderBloc>().add(RetryDownloadEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, bookmarkState) {
        return DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: _defaultAppBar(context, bookmarkState),
            body: const TabBarView(
              children: [
                SurahNamesWidget(),
                JuzNamesWidget(),
                MoreDisplayWidget()
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _defaultAppBar(BuildContext context, BookmarkState bookmarkState) {
    return AppBar(
      title: const Text(AppStrings.appName),
      actions: [
        IconButton(
          onPressed: () {
            context.push('/developer_screen');
          },
          icon: const Icon(Icons.developer_mode),
        ),
        // Go To last read
        IconButton(
          enableFeedback: true,
          tooltip: "Go to last read",
          onPressed: () {
            // dispatching the event
            context.read<BookmarkBloc>().add(RedirectToBookmarkEvent(
                  context: context,
                ));

            // then redirecting
            if (bookmarkState.lastRead["surah_index"] != null) {
              switch (bookmarkState.bookmarkType) {
                case BookmarkType.surah:
                  context.push("/surah_display_screen");
                  break;
                case BookmarkType.juz:
                  context.push("/juz_display_screen");
                  break;
              }
            }
          },
          icon: bookmarkState.lastRead["surah_index"] == null
              ? const Icon(Icons.bookmark_border_rounded)
              : const Icon(Icons.bookmark_rounded),
        ), // DEVELOPER SCREEN

        IconButton(
            onPressed: () {
              context.push('/favourites_screen');
            },
            icon: bookmarkState.favourites.isEmpty
                ? const Icon(Icons.star_border_rounded)
                : const Icon(Icons.star_rounded)),
        IconButton(
          onPressed: () {
            context.push('/settings');
          },
          icon: const Icon(Icons.settings),
          tooltip: "Settings",
        ),
      ],
      bottom: const TabBar(
        indicatorWeight: 3.5,
        tabs: [
          Tab(
            text: "Surahs",
          ),
          Tab(
            text: "Juz",
          ),
          Tab(
            text: "More",
          ),
        ],
      ),
    );
  }
}
