import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../surah_display_bloc/surah_display_bloc.dart';
import '../surah_tracker_bloc/surah_tracker_bloc.dart';

part 'display_type_switcher_event.dart';

part 'display_type_switcher_state.dart';

class DisplayTypeSwitcherBloc
    extends Bloc<DisplayTypeSwitcherEvent, DisplayTypeSwitcherState> {
  final SurahDisplayBloc surahDisplayBloc;
  final SurahTrackerBloc surahTrackerBloc;

  DisplayTypeSwitcherBloc({
    required this.surahDisplayBloc,
    required this.surahTrackerBloc,
  }) : super(const DisplayTypeSwitcherState()) {
    on<UpdateMushafModeEvent>((event, emit) {
      // if the isMushafMode is specified then load the state with that value
      if (event.isMushafMode != null) {
        return emit(state.copyWith(isMushafMode: event.isMushafMode!));
      }
      // else toggle the value
      else {
        emit(state.copyWith(isMushafMode: !state.isMushafMode));
      }
      // // this will be executed for mushaf mode
      //
      // List pages = surahDisplayBloc.state.surahData!
      //     .map((e) => e["page_number"])
      //     .toSet()
      //     .toList();
      // if (state.isMushafMode == false) {
      //   final int currentScrolledVerseIndex =
      //       surahTrackerBloc.state.verseByVerseScrolledVerseIndex!;
      //
      //   int currentActualPageNumber = surahDisplayBloc
      //       .state.surahData![currentScrolledVerseIndex]["page_number"];
      //
      //   emit(state.copyWith(
      //       isMushafMode: true,
      //       convertedReadingScrollPositionIndex:
      //           pages.indexOf(currentActualPageNumber)));
      // }
      // // this will be executed for verse by verse mode
      // else {
      //   final int currentScrolledPageIndex =
      //       surahTrackerBloc.state.mushafModeScrolledPageIndex!;
      //
      //   int actualPageNumber = pages[currentScrolledPageIndex];
      //
      //   Logger().i(
      //       "currentScrolledPageIndex from xxxxxx : $currentScrolledPageIndex | actualPageNumber from xxxxxx : $actualPageNumber");
      //
      //   final verseIndex = surahDisplayBloc.state.surahData!.indexWhere(
      //       (element) => element["page_number"] == actualPageNumber);
      //
      //   Logger().i("verseIndex from xxxxxx : $verseIndex");
      //
      //   emit(
      //     state.copyWith(
      //       isMushafMode: false,
      //       convertedReadingScrollPositionIndex: verseIndex,
      //     ),
      //   );
      // }
    });

    /* this will be executed when the tabs change cause if don't reset the convertedReadingScrollPositionIndex
    * then every time the user switches the surah it would be stating from the last position*/
    on<ResetConvertedReadingScrollPositionIndexEvent>((event, emit) async {
      // state.mushafItemScrollController!.jumpTo(index: 0);
      // state.verseByVerseItemScrollController!.jumpTo(index: 0);
      emit(state.copyWith(convertedReadingScrollPositionIndex: 0));

      Logger().i(
          "ResetConvertedReadingScrollPositionIndexEvent : ${state.convertedReadingScrollPositionIndex}");
    });

    on<GetVerseByVerseItemScrollControllerEvent>((event, emit) async {
      emit(state.copyWith(
          verseByVerseItemScrollController: event.itemScrollController));
    });

    on<GetMushafItemScrollControllerEvent>((event, emit) async {
      emit(state.copyWith(
          mushafItemScrollController: event.itemScrollController));
    });
  }
}
