import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'language_event.dart';

part 'language_state.dart';

class LanguageBloc extends HydratedBloc<LanguageEvent, LanguageState> {
  // this will be the default language
  static Map<String, dynamic> defaultLanguage =
      AppVariables.defaultSelectedLanguage;

  LanguageBloc() : super(const LanguageState()) {
    // FETCH AVAILABLE LANGUAGES
    on<FetchAvailableLanguagesEvent>((event, emit) async {
      if (LocalDataRepository.getStoredAvailableLanguages() != null) {
        final languages = LocalDataRepository.getStoredAvailableLanguages();
        emit(state.copyWith(
            areLanguagesDownloaded: false,
            allLanguages: languages,
            selectedLanguage: state.selectedLanguage));
      } else {
        await InternetDataRepository.getAvailableLanguages(
            onCompleted: (languages) {
          emit(state.copyWith(
            areLanguagesDownloaded: true,
            allLanguages: languages,
          ));
        }, onError: (error) {
          emit(state.copyWith(
            areLanguagesDownloaded: false,
            isError: true,
          ));
        });
      }
    });

    // SELECT LANGUAGE EVENT handler
    on<SelectedLanguageEvent>((event, emit) {
      emit(state.copyWith(selectedLanguage: event.selectedLanguage));
    });

    // SEARCH LANGUAGE EVENT handler
    on<SearchLanguageEvent>((event, emit) {
      final query = event.searchQuery.toLowerCase();
      final List searchResults = state.allLanguages!.where((language) {
        final String name = language["name"].toString().toLowerCase();
        final String isoCode = language["iso_code"].toString().toLowerCase();
        return name.contains(query) || isoCode.contains(query);
      }).toList();
      emit(state.copyWith(searchQuery: query, searchResults: searchResults));
    });

    // retry languages download

    on<RetryLanguagesDownloadEvent>((event, emit) async {
      emit(state.copyWith(areLanguagesDownloaded: false, isError: false));
      await InternetDataRepository.getAvailableLanguages(
          onCompleted: (languages) {
        emit(state.copyWith(
          areLanguagesDownloaded: true,
          allLanguages: languages,
        ));
      }, onError: (error) {
        emit(state.copyWith(
          areLanguagesDownloaded: false,
          isError: true,
        ));
      });
    });
  }

  // ============== ============================ END ==============================
  // ============== ============================ ==============================
  // ============== ============================ ==============================
  // ============== ============================ ==============================
  // HYDRATED BLOC
  @override
  LanguageState? fromJson(Map<String, dynamic> json) {
    return LanguageState(
        areLanguagesDownloaded: json["areLanguagesDownloaded"],
        selectedLanguage: json["selectedLanguage"],
        allLanguages: json["allLanguages"]);
  }

  @override
  Map<String, dynamic>? toJson(LanguageState state) {
    return {
      "areLanguagesDownloaded": state.areLanguagesDownloaded,
      "selectedLanguage": state.selectedLanguage,
      "allLanguages": state.allLanguages
      //not saving [allLanguages] in state as they are fetched from whenever necessary and are not used often
      // if i retain them using sate it would be a waste of memory
    };
  }
}
