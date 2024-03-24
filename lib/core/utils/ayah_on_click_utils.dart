import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../logic/bookmark_bloc/bookmark_bloc.dart';

class AyahOnClickMenuUtils {
  static Widget showFavourite(
      {required int surahOrJuzIndex,
      required List features,
      required int verseIndex,
      required BuildContext context}) {
    const int i = 3;
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, bookmarkState) {
        bool isFavourite = bookmarkState.favourites.any((element) =>
            element["surahIndex"] == surahOrJuzIndex &&
            element["verseIndex"] == verseIndex);

        // if favourite show remove from favourite option
        if (isFavourite) {
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: () {
              context.read<BookmarkBloc>().add(RemoveFromFavouritesEvent(
                    surahIndex: surahOrJuzIndex,
                    verseIndex: verseIndex,
                  ));
              context.pop();
            },
            child: Row(
              children: [
                Icon(
                  Icons.remove_circle_rounded,
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Remove from Favourites",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else {
          // if not favourite show add to favourite option
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: features[i]["onPressed"],
            child: Row(
              children: [
                Icon(
                  features[i]["icon"],
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  features[i]["name"],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
      },
    );
  }

//

  // show bookmarked
  static Widget showBookmarked(
      {required BuildContext context,
      required List features,
      required int verseIndex,
      required int surahOrJuzIndex}) {
    const int i = 2;
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        // if bookmark show remove bookmark option
        if (state.lastRead["verse_index"] == verseIndex &&
            state.lastRead["surah_index"] == surahOrJuzIndex - 1) {
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: () {
              context.read<BookmarkBloc>().add(RemoveBookmarkEvent());
              context.pop();
            },
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_remove_rounded,
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Remove from Last Read",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else {
          // if not bookmark show add bookmark option
          return TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 5.w,
                ),
              ),
            ),
            onPressed: features[i]["onPressed"],
            child: Row(
              children: [
                Icon(
                  features[i]["icon"],
                  size: 21.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  features[i]["name"],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
