import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../language_bloc/language_bloc.dart';

part 'tafsir_event.dart';

part 'tafsir_state.dart';

class TafsirBloc extends Bloc<TafsirEvent, TafsirState> {
  final LanguageBloc languageBloc;

  TafsirBloc({required this.languageBloc}) : super(TafsirState()) {
    // GET ALL TAFSIR METADATA event
    on<GetAllTafsirsMetaData>((event, emit) async {
      emit(state.copyWith(isError: false));
      await InternetDataRepository().getAllTafsirIds(
        // On data received
        onCompleted: (data) {
          // filtering the selected language specific data
          List<dynamic> languageSpecificTafsirIds = data
              .where((element) =>
                  element['language_name'] ==
                  languageBloc.state.selectedLanguage["name"].toLowerCase())
              .toList();

          //  if the selected language specific data is empty, then get the english data as default
          //  cause the tafsir for every language in not available
          if (languageSpecificTafsirIds.isEmpty) {
            languageSpecificTafsirIds = data
                .where((element) => element['language_name'] == "english")
                .toList();
          }
          // data contains all languages tafsir ids
          emit(state.copyWith(
            allTafsirIdsMetaData: data,
            languageSpecificTafsirIdsMetaData: languageSpecificTafsirIds,
          ));

          // Getting the first tafsir data
          add(GetTafsirEvent(
              tafsirId: languageSpecificTafsirIds[0]['id'],
              surahId: event.surahId,
              verseId: event.verseId));

          // filtering the selected language specific data
        },

        // On error
        onError: (error) {
          Logger().e(error);
          emit(state.copyWith(isError: true));
        },
      );
    });

    // GET TAFSIR event
    on<GetTafsirEvent>((event, emit) async {
      await InternetDataRepository.getTafsir(
        tafsirId: event.tafsirId.toString(),
        surahId: event.surahId.toString(),
        verseId: event.verseId.toString(),

        // On data received
        onCompleted: (data) {
          // Logger().i("data : ${data}");
          emit(state.copyWith(
            tafsirData: data,
          ));
        },
        // On error
        onError: (error) {
          Logger().e(error);
          emit(state.copyWith(isError: true));
        },
      );
    });
  }
}
