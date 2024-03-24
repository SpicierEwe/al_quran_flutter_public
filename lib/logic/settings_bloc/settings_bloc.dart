import 'dart:async';

import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../../core/constants/non_segmented_reciters.dart';
import '../repositories/internet_data_repository.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsEventChangeQuranFont>((event, emit) {
      emit(state.copyWith(
          selectedQuranScriptIndex: event.index,
          selectedQuranScriptType: event.fontName.toLowerCase()));
    });

    on<SettingsEventGetAllTranslationIds>((event, emit) {
      final translationIds = LocalDataRepository.getStoredTranslationIds(
          languageName: event.languageName);

      emit(state.copyWith(translationIds: translationIds));
    });

    on<SettingsEventChangeTranslation>((event, emit) {
      emit(state.copyWith(selectedTranslationId: event.translationId));
    });

    //   update reciter id
    on<UpdateSelectedReciterIdEvent>((event, emit) {
      emit(state.copyWith(selectedReciterId: event.reciterId));
    });

    //   update translation font size
    on<UpdateTranslationFontSizeEvent>((event, emit) {
      if (event.shouldIncrease) {
        if (state.translationFontSize <
            AppVariables.translationMaxFontSizeLimit) {
          emit(state.copyWith(
              translationFontSize: state.translationFontSize + 1));
        }
      } else {
        if (state.translationFontSize >
            AppVariables.translationMinFontSizeLimit) {
          emit(state.copyWith(
              translationFontSize: state.translationFontSize - 1));
        }
      }
    });

    //   update quran text font size
    on<UpdateQuranTextFontSizeEvent>((event, emit) {
      if (event.shouldIncrease) {
        if (state.quranTextFontSize < AppVariables.quranMaxFontSizeLimit) {
          emit(state.copyWith(quranTextFontSize: state.quranTextFontSize + 1));
        }
      } else {
        if (state.quranTextFontSize > AppVariables.quranMinFontSizeLimit) {
          emit(state.copyWith(quranTextFontSize: state.quranTextFontSize - 1));
        }
      }
    });

    //   update quran text word spacing
    on<UpdateQuranTextWordSpacingEvent>((event, emit) {
      if (event.shouldIncrease) {
        if (state.quranTextWordSpacing < AppVariables.wordSpacingMaxLimit) {
          emit(state.copyWith(
              quranTextWordSpacing: state.quranTextWordSpacing + 1));
        }
      } else {
        if (state.quranTextWordSpacing > AppVariables.wordSpacingMinLimit) {
          emit(state.copyWith(
              quranTextWordSpacing: state.quranTextWordSpacing - 1));
        }
      }
    });

    //   toggle transliteration
    on<SettingsEventToggleTransliteration>((event, emit) {
      emit(state.copyWith(showTransliteration: !state.showTransliteration));
    });

    //   get all reciters

    on<SettingsEventGetAllReciters>(
      (event, emit) async {
        if (state.allRecitersList.isNotEmpty) return;
        await InternetDataRepository().getAllReciters(
          onCompleted: (reciters) {
            List tempRecitersList = reciters;
            // make alafasy reciter the first reciter
            // extracting alafasy reciter from the list
            List filteredList = reciters
                .where((element) => element["id"].toString() == "7")
                .toList();
            // removing alafasy reciter from the main list
            tempRecitersList
                .removeWhere((element) => element["id"].toString() == "7");
            emit(state.copyWith(allRecitersList: [
              ...filteredList,
              ...reciters,
              ...NonSegmentedRecitersClass.reciters,
              ...NonSegmentedRecitersClass.translations
            ]));
          },
          onError: (error) {
            print('Error: $error');
          },
        );
      },
    );
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState(
        selectedQuranScriptIndex: json["selectedQuranScriptIndex"],
        selectedQuranScriptType: json["selectedQuranScriptType"],
        selectedTranslationId: json["selectedTranslationId"],
        translationFontSize: json["translationFontSize"],
        quranTextFontSize: json["quranTextFontSize"],
        quranTextWordSpacing: json["quranTextWordSpacing"],
        selectedReciterId: json["selectedReciterId"],
        showTransliteration: json["showTransliteration"],
        translationIds: json["translationIds"],
      );
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    try {
      return {
        "selectedQuranScriptIndex": state.selectedQuranScriptIndex,
        "selectedQuranScriptType": state.selectedQuranScriptType,
        "selectedTranslationId": state.selectedTranslationId,
        "translationFontSize": state.translationFontSize,
        "quranTextFontSize": state.quranTextFontSize,
        "quranTextWordSpacing": state.quranTextWordSpacing,
        "selectedReciterId": state.selectedReciterId,
        "showTransliteration": state.showTransliteration,
        "translationIds": state.translationIds,
      };
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }
}
