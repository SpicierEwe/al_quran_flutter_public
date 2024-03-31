import 'dart:async';

import 'package:al_quran_new/logic/juz_display_bloc/juz_display_bloc.dart';
import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:logger/logger.dart';

import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'surah_tracker_event.dart';

part 'surah_tracker_state.dart';

class SurahTrackerBloc extends Bloc<SurahTrackerEvent, SurahTrackerState> {
  SurahDisplayBloc surahDisplayBloc;
  JuzDisplayBloc juzDisplayBloc;

  SurahTrackerBloc(
      {required this.juzDisplayBloc, required this.surahDisplayBloc})
      : super(const SurahTrackerState()) {
    // Surah Display  ======
    on<SurahDisplayUpdatePageHizbManzilVerseByVerseModeEvent>(
      (event, emit) async {
        {
          emit(state.copyWith(
            pageHizbManzilData: [
              surahDisplayBloc.state.surahData![event.scrollPositionIndex]
                  ["page_number"],
              surahDisplayBloc.state.surahData![event.scrollPositionIndex]
                  ["hizb_number"],
              surahDisplayBloc.state.surahData![event.scrollPositionIndex]
                  ["manzil_number"]
            ],
            verseByVerseScrolledVerseIndex: event.scrollPositionIndex,
            chapterId: event.chapterId,
          ));

          Logger().i(
              "scrollPositionIndex  : ${event.scrollPositionIndex} event_chapterId : ${event.chapterId} state_chapter_id : ${state.chapterId} ");
        }
      },
    );

    // Surah update hisb manzil page mushaf mode  ======
    on<SurahDisplayUpdatePageHizbManzilMushafModeEvent>((event, emit) async {
      int pageIndex = event.scrollPositionIndex;

      List pages = surahDisplayBloc.state.surahData!
          .map((e) => e["page_number"])
          .toSet()
          .toList();
      /* as the pages have no independent refrence in the data so in order to get the hisb we are 1st we are collecting all the
      * pages with the page from the event after that we separate the hizb as list then when display them as strings if length of
      * the hisb array is 1 then simply like hisb 1 if more then the hizb on index 0 and last index is taken and is displayed as ex:
      *  Hizb 1 -4 */

      // collecting the data of the page from the event
      List pageData = surahDisplayBloc.state.surahData!
          .where((element) => element["page_number"] == pages[pageIndex])
          .toList();

      // collecting the hizb from the page data
      List hisbList = pageData.map((e) => e["hizb_number"]).toSet().toList();

      // converting the hisb list to string
      String hisbString = hisbList.length > 1
          ? "${hisbList[0]} - ${hisbList[hisbList.length - 1]}"
          : hisbList[0].toString();

      // Logger().i("pages  : " + pages.toString());
      // Logger().i("hisbData  : " + hisbList.toString());

      // the manzil data is 0 as im not using it anywhere so i just put it as 0 for now if in future u want to determine the manzil to
      // be displayed then u can use the same logic as used for hizb. the mazil is already updated in the verse by verse mode so only
      // its here to be updated later
      emit(state.copyWith(
        pageHizbManzilData: [pages[pageIndex], hisbString, 0],
        mushafModeScrolledPageIndex: pageIndex,
      ));
    });

    on<UpdateHighlightWordEvent>((event, emit) async {
      emit(state.copyWith(highlightWord: event.wordLocation));
    });

    // JUZ Display  ====== ===
    //  =======================================
    //  =======================================
    on<JuzDisplayUpdatePageHizbManzilVerseByVerseModeEvent>(
        (event, emit) async {
      {
        emit(state.copyWith(
          pageHizbManzilData: [
            juzDisplayBloc.state.juzData![event.scrollPositionIndex]
                ["page_number"],
            juzDisplayBloc.state.juzData![event.scrollPositionIndex]
                ["hizb_number"],
            juzDisplayBloc.state.juzData![event.scrollPositionIndex]
                ["manzil_number"]
          ],
          verseByVerseScrolledVerseIndex: event.scrollPositionIndex,
          juzId: event.juzId,
        ));

        Logger().i(
            "Juz :: scrollPositionIndex  : ${event.scrollPositionIndex} JUZ :: JuzID : ${event.juzId} JUZ :: state_juzId : ${state.juzId} ");
      }
    });

    on<JuzDisplayUpdatePageHizbManzilMushafModeEvent>((event, emit) async {
      int pageIndex = event.scrollPositionIndex;

      List pages = juzDisplayBloc.state.juzData!
          .map((e) => e["page_number"])
          .toSet()
          .toList();
      /* as the pages have no independent refrence in the data so in order to get the hisb we are 1st we are collecting all the
      * pages with the page from the event after that we separate the hizb as list then when display them as strings if length of
      * the hisb array is 1 then simply like hisb 1 if more then the hizb on index 0 and last index is taken and is displayed as ex:
      *  Hizb 1 -4 */

      // collecting the data of the page from the event
      List pageData = juzDisplayBloc.state.juzData!
          .where((element) => element["page_number"] == pages[pageIndex])
          .toList();

      // collecting the hizb from the page data
      List hisbList = pageData.map((e) => e["hizb_number"]).toSet().toList();

      // converting the hisb list to string
      String hisbString = hisbList.length > 1
          ? "${hisbList[0]} - ${hisbList[hisbList.length - 1]}"
          : hisbList[0].toString();

      // Logger().i("pages  : " + pages.toString());
      // Logger().i("hisbData  : " + hisbList.toString());

      // the manzil data is 0 as im not using it anywhere so i just put it as 0 for now if in future u want to determine the manzil to
      // be displayed then u can use the same logic as used for hizb. the mazil is already updated in the verse by verse mode so only
      // its here to be updated later
      emit(state.copyWith(
        pageHizbManzilData: [pages[pageIndex], hisbString, 0],
        mushafModeScrolledPageIndex: pageIndex,
      ));
    });
  }
}
