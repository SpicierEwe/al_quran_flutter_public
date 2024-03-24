import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../../core/constants/variables.dart';
import '../repositories/local_data_repository.dart';

part 'juz_display_event.dart';

part 'juz_display_state.dart';

class JuzDisplayBloc extends Bloc<JuzDisplayEvent, JuzDisplayState> {
  JuzDisplayBloc() : super(const JuzDisplayState()) {
    // update selectedJuzIndex
    on<UpdateSelectedJuzId>((event, emit) {
      emit(state.copyWith(selectedJuzId: event.selectedJuzId));
    });

    //   juz data

    // the data here is not displayed in the ui
    //  the main use of the data is to help track the page numbers etc during scrolling
    on<DisplayJuzEvent>((event, emit) {
      Logger().i("DisplayJuzEvent : ${event.selectedJuzNumber}");
      final List juzData = [];
      final List juzTranslatedData = [];
      final Map<String, String> juzMetaData = AppVariables
          .juzMetaData[event.selectedJuzNumber - 1]["verse_mapping"];

      juzMetaData.forEach((key, value) {
        int chapterId = int.parse(key);
        int verseStart = int.parse(value.split("-")[0]);
        int verseEnd = int.parse(value.split("-")[1]);
        String keyValue = value;
        Logger().i("key : $key, value : $value");

        final List surahDataTemp =
            LocalDataRepository.getStoredQuranArabicChapter(
          chapterId: chapterId,
        )!;

        final List translatedDataTemp =
            LocalDataRepository.getStoredQuranChapterTranslation(
          chapterId: chapterId,
          translationId: event.selectedTranslationId,
        )!;

        juzData.addAll(surahDataTemp.sublist(verseStart - 1, verseEnd));
        juzTranslatedData
            .addAll(translatedDataTemp.sublist(verseStart - 1, verseEnd));
      });

      // Logger().t("juzData : $juzData");

      emit(
        state.copyWith(
          juzData: juzData,
          juzTranslationData: juzTranslatedData,
        ),
      );
    });
  }
}
