import 'dart:async';

import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../language_bloc/language_bloc.dart';

part 'surah_info_event.dart';

part 'surah_info_state.dart';

class SurahInfoBloc extends Bloc<SurahInfoEvent, SurahInfoState> {
  final LanguageBloc languageBloc;

  SurahInfoBloc({required this.languageBloc}) : super(const SurahInfoState()) {
    // get the surah info
    on<GetSurahInfo>((event, emit) async {
      Completer<void> completer = Completer<void>();

      emit(state.copyWith(
        isError: false,
      ));
      // checking if there is stored surah data
      LocalDataRepository.getStoredSurahInfo(
          surahId: event.surahId.toString(),
          languageIsoCode: languageBloc.state.selectedLanguage["iso_code"],
          // if the data is retrieved, emit it
          onRetrieved: (data) {
            emit(state.copyWith(surahInfo: data));
            completer.complete();
          },

          // if there is no stored data, get the data from the internet
          dataNotFound: (error) async {
            // get the surah info from the internet
            await InternetDataRepository.getSurahInfo(
                surahId: event.surahId.toString(),
                languageIsoCode:
                    languageBloc.state.selectedLanguage["iso_code"],

                // if the data is retrieved, store it
                onCompleted: (data) {
                  emit(state.copyWith(surahInfo: data));
                  completer.complete();
                },

                // if there is an error, emit the error
                onError: (error) {
                  emit(state.copyWith(
                    isError: true,
                  ));
                  completer.complete();
                });
          });

      await completer.future;
    });
  }
}
