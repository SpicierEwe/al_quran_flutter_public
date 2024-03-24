import 'dart:async';

import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../language_bloc/language_bloc.dart';

part 'surah_display_event.dart';

part 'surah_display_state.dart';

class SurahDisplayBloc extends Bloc<SurahDisplayEvent, SurahDisplayState> {
  SurahDisplayBloc() : super(const SurahDisplayState()) {
    // =============== =========================== =================== =============== //
    on<SelectedSurahNumberEvent>((event, emit) =>
        emit(state.copyWith(selectedSurahNumber: event.selectedSurahNumber)));

    // This is used to listen to the events and change the state accordingly
    //
    // display surah event is used to change the selected surah number and display the surah accordingly
    on<DisplaySurahEvent>((event, emit) async {
      // emit(state.copyWith(selectedSurahNumber: event.selectedSurahNumber));
      try {
        // clear the stored data for all the surahs except the selected surah

        final chapter = LocalDataRepository.getStoredQuranArabicChapter(
            chapterId: event.selectedSurahNumber);

        final chapterTranslationData =
            LocalDataRepository.getStoredQuranChapterTranslation(
                chapterId: event.selectedSurahNumber,
                translationId: event.selectedTranslationId);

        // Logger().i("Surah data = $surahData");
        // Logger().i("translation data = $chapterTranslationData");

        emit(state.copyWith(
            surahData: chapter,
            chapterTranslationData: chapterTranslationData));

        // Logger().i(event.selectedSurahNumber);
      } catch (e) {
        Logger().e(e);
      }

      // print("Surah Display Bloc: Display Surah Event");
      // print(surahData);

      // final List? data = LocalDataRepository.getStoredQuranArabicChapter(
      //     chapterId: state.selectedSurahNumber!); // get the stored data
      //
      // emit(state.copyWith(surahData: data)); // change the state
    });
  }
}
