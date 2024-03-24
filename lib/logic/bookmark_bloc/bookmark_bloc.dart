import 'dart:async';

import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants/enums.dart';
import '../../presentation/surah_display_screen/surah_display_screen.dart';
import '../display_type_switcher_bloc/display_type_switcher_bloc.dart';
import '../juz_display_bloc/juz_display_bloc.dart';
import '../settings_bloc/settings_bloc.dart';
import '../surah_display_bloc/surah_display_bloc.dart';
import '../surah_tracker_bloc/surah_tracker_bloc.dart';

part 'bookmark_event.dart';

part 'bookmark_state.dart';

class BookmarkBloc extends HydratedBloc<BookmarkEvent, BookmarkState> {
  final SurahDisplayBloc surahDisplayBloc;
  final JuzDisplayBloc juzDisplayBloc;
  final DisplayTypeSwitcherBloc displayTypeSwitcherBloc;

  BookmarkBloc({
    required this.surahDisplayBloc,
    required this.displayTypeSwitcherBloc,
    required this.juzDisplayBloc,
  }) : super(const BookmarkState()) {
    // getting juz and page index
    on<AddBookmarkEvent>((event, emit) {
      final List? surahData = LocalDataRepository.getStoredQuranArabicChapter(
          chapterId: event.surahIndex + 1);

      int pageIndex = surahData?[event.verseIndex]["page_number"] - 1;
      int juzIndex = surahData?[event.verseIndex]["juz_number"] - 1;

      Logger().i("page Index for bookmarked verse : $pageIndex");

      emit(state.copyWith(
        lastRead: {
          "surah_index": event.surahIndex,
          "verse_index": event.verseIndex,
          "page_index": pageIndex,
          "juz_index": juzIndex,
        },
        bookmarkType: event.bookmarkType,
      ));
      Logger().i("Bookmark Added : ${state.lastRead}");
    });

    // removing bookmark
    on<RemoveBookmarkEvent>((event, emit) {
      emit(state.copyWith(lastRead: {
        "verseIndex": null,
        "surahIndex": null,
        "page_index": null,
        "juz_index": null,
      }));
    });

    /*
    * we dont need controller to redirect cause the tabs are automatically selected for the selected surah or juz id so we just have to update the selected ids
    * as for the verse scroll to index then we give the initial index as the bookmark index so its automatically scrolled */
    // redirecting to bookmark

    on<RedirectToBookmarkEvent>(
      (event, emit) {
        // if surah index is null ( only checking one field cause this is the most important one if it is null then other fields wont work )
        if (state.lastRead["surah_index"] == null) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.red,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "No Last Read found",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          );

          return;
        } else {
          // redirecting to the bookmark

          switch (state.bookmarkType) {
            case BookmarkType.surah:
              // settings the selected surah so that data loads for that specific surah
              surahDisplayBloc.add(SelectedSurahNumberEvent(
                  selectedSurahNumber: state.lastRead["surah_index"]! + 1));
              break;
            case BookmarkType.juz:
              // settings the selected surah so that data loads for that specific surah
              juzDisplayBloc.add(UpdateSelectedJuzId(
                  selectedJuzId: state.lastRead["juz_index"]! + 1));
              break;
          }

          // settings the selected surah so that data loads for that specific surah
          surahDisplayBloc.add(SelectedSurahNumberEvent(
              selectedSurahNumber: state.lastRead["surah_index"]! + 1));
        }
      },
    );

    // this event is fired when user clicks on the favourite verse in the favourite list
    /*
    * THE REDIRECTION OF FAVOURITE VERSE IS ONLY CURRENTLY SUPPORTED FOR THE SURAH VERSE BY VERSE MODE */
    on<RedirectToFavouriteEvent>(
      (event, emit) {
        // THIS CODE CANNBE USED IF YOU EVENT TRY TO IMPLEMENT FOR THE MUSHAF MODE
        // final List? surahData = LocalDataRepository.getStoredQuranArabicChapter(
        //     chapterId: event.surahIndex + 1);
        //
        // List pagesList =
        //     surahData!.map((e) => e["page_number"]).toSet().toList();
        //
        // int realPageNumber = surahData[event.verseIndex]["page_number"];
        // int localPageIndex = pagesList.indexOf(realPageNumber);

        Logger().i("page Index for bookmarked verse : ${event.verseIndex}");
        // redirecting to the favourite

        // settings the selected surah so that data loads for that specific surah
        surahDisplayBloc.add(SelectedSurahNumberEvent(
            selectedSurahNumber: event.surahIndex + 1));

        // i dont redirect if the page in in mushaf mode so i change the mode to
        // surah mode 1st before doing anything further
        displayTypeSwitcherBloc.add(UpdateMushafModeEvent(
          isMushafMode: false,
        ));

        return emit(
          state.copyWith(
            redirectFavouriteVerseIndex: event.verseIndex,
          ),
        );
      },
    );

    // scrolling to the favourite verse
    /* this event fires after the user clicks on the favourite verse then when the user is
    * redirected on the surah screen, Then this is fired in the initState in order to scroll to
    * that verse */
    on<ScrollToFavouriteVerseEvent>(
      (event, emit) async {
        // if the redirect favourite index is null then we dont do anything
        if (state.redirectFavouriteVerseIndex != -1) {
          Logger().i(
              "Scrolling to favourite verse : ${state.redirectFavouriteVerseIndex}");

          // scrolling to the favourite verse
          await event.itemScrollController.scrollTo(
            // scrolling to the favourite verse
            index: state.redirectFavouriteVerseIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          // removing the redirect favourite index so that its not fired again
          emit(
            state.copyWith(
              redirectFavouriteVerseIndex: -1,
            ),
          );
        }
      },
    );

    //   ====================== AddToFavouritesEvent  ======================

    on<AddToFavouritesEvent>((event, emit) {
      // if the verse is already in the favourites then we remove it
      final List? surahData = LocalDataRepository.getStoredQuranArabicChapter(
          chapterId: event.surahIndex + 1);

      int pageIndex = surahData?[event.verseIndex]["page_number"] - 1;
      int juzIndex = surahData?[event.verseIndex]["juz_number"] - 1;

      /*
      * checking if the verse in already in favourites,
      * if its not we will add to the favourites
      * if its already there we will not do anything */
      if (!state.favourites.any((fav) =>
          fav["surahIndex"] == event.surahIndex &&
          fav["verseIndex"] == event.verseIndex &&
          fav["page_index"] == pageIndex &&
          fav["juz_index"] == juzIndex)) {
        // adding verse to favourites
        emit(state.copyWith(favourites: [
          ...state.favourites,
          {
            "surahIndex": event.surahIndex,
            "verseIndex": event.verseIndex,
            "page_index": pageIndex,
            "juz_index": juzIndex
          }
        ]));
        return;
      }
    });

    // removing from favourites
    on<RemoveFromFavouritesEvent>((event, emit) {
      List<dynamic> newFavourites = state.favourites
          .where((element) =>
              element["surahIndex"] != event.surahIndex ||
              element["verseIndex"] != event.verseIndex)
          .toList();
      emit(state.copyWith(
          favourites: newFavourites)); // removing verse from favourites
    });
  }

  @override
  BookmarkState? fromJson(Map<String, dynamic> json) {
    try {
      return BookmarkState(
        lastRead: json["lastRead"],
        // converting string to enum as enums cant be stored in json
        bookmarkType: json["bookmarkType"] == "surah"
            ? BookmarkType.surah
            : BookmarkType.juz,
        favourites: json["favourites"],
      );
    } catch (e) {
      Logger().e("Error in BookmarkBloc.fromJson : $e");
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(BookmarkState state) {
    try {
      return {
        "lastRead": state.lastRead,
        // converting enum to string as enums cant be stored in json
        "bookmarkType": state.bookmarkType.toString().split(".").last,
        "favourites": state.favourites,
      };
    } catch (e) {
      Logger().e("Error in BookmarkBloc.toJson : $e");
    }
    return null;
  }
}
