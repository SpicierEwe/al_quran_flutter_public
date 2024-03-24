// Import necessary packages and files
import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../language_bloc/language_bloc.dart';
import '../settings_bloc/settings_bloc.dart';

// Import generated parts for event and state
part 'downloader_event.dart';

part 'downloader_state.dart';

// Define a BLoC class for handling download operations
class DownloaderBloc extends HydratedBloc<DownloaderEvent, DownloaderState> {
  LanguageBloc languageBloc;
  SurahNamesBloc surahNamesBloc;
  SettingsBloc settingsBloc;

  // Constructor for initializing the BLoC with an initial state
  DownloaderBloc({
    required this.languageBloc,
    required this.surahNamesBloc,
    required this.settingsBloc,
  }) : super(const DownloaderState()) {
    //
    //
    // ========================== Event Handling ==========================
    // Warning! It seems to me that somehow the isError is becoming true when using hydrated bloc
    // and it seems that onyl retry function is running and DownloadQuranEvent function is not running
    // whatever data is being downloaded its being downloaded through the retry function
    //

    // Define the behavior for handling the DownloadQuranEvent
    on<DownloadQuranEvent>((event, emit) async {
      // Initial state for download
      emit(state.copyWith(
        message: "Download Starting now...",
        isErrorInTranslationDownload: false,
        isErrorInTranslationIdsDownload: false,
        isAllDataDownloaded: false,

        // if only language change then we will not download the quran again
        isQuranDownloaded:
            event.isOnlyLanguageChange ? state.isQuranDownloaded : false,
        areTranslationIdsDownloaded: false,
        isTranslationDownloaded: false,
        progressPercentage: "0",
        isSurahNamesMetaDataDownloaded: false,

        // ====
        isError: false,
        isSnackbarVisible: true,
        isDownloading: true,
      ));

      // download surah names metadata
      await _downloadSurahNamesMetaData(emit: emit);

      // if only language change then we will not download the surah names metadata again
      // Quran Download
      if (event.isOnlyLanguageChange == false) {
        await _downloadQuran(emit: emit);
      }

      // Translation Ids Download
      await _downloadTranslationIds(emit: emit);
      //

      // Download the first translation
      await extractIdAndDownloadTranslation(emit: emit);

      //
      // // Final emit to indicate completion or failure

      _finalEmit(emit: emit);
    });

    // Retry Download Event Handling
    on<RetryDownloadEvent>((event, emit) async {
      emit(state.copyWith(
        message: "Retrying download...",
        isError: false,
        isSnackbarVisible: true,
        isDownloading: true,
      ));

      if (state.isSurahNamesMetaDataDownloaded == false) {
        await _downloadSurahNamesMetaData(emit: emit);
      }

      // Quran Download

      if (state.isQuranDownloaded == false) {
        await _downloadQuran(emit: emit);
      }

      // Translation Ids Download
      if (state.areTranslationIdsDownloaded == false) {
        await _downloadTranslationIds(emit: emit);
      }

      await extractIdAndDownloadTranslation(emit: emit, isRetrying: true);

      // Final emit to indicate completion or failure
      _finalEmit(emit: emit);
    });

    on<DownloadAdditionalTranslationEvent>((event, emit) async {
      await _downloadAdditionalFullQuranTranslation(
        context: event.context,
        emit: emit,
        translationId: event.translationId,
      );

      // Final emit to indicate completion or failure
    });
  }

  // Function to extract the 1st translation id from list and download the translation
  Future<void> extractIdAndDownloadTranslation(
      {required emit, bool isRetrying = false}) async {
    // re-usable function
    Future<void> extractionIdAndDownloadTranslation() async {
      List<Map<String, dynamic>> translationIds =
          LocalDataRepository.getStoredTranslationIds(
              languageName: languageBloc.state.selectedLanguage["name"]
                  .toString()
                  .toLowerCase());
      // if the transactional ids is not empty then download the translation
      if (translationIds.isNotEmpty) {
        // updating the default translation id here
        /*
        * check if the already default translation id is present in the downloaded translation ids
        * if its present we wont change the id to the id at 0 index
         */

        // checking if already selected id exists in the downloaded translation ids
        /*
        *  for example if the user is fetching the data using settings update data
        * then the user has already selected a translation of his choice so we need to check if the selected translation id exists in the downloaded translation ids cause new data can
        * be changed where the server doesn't have the translation that the user has selected.
        *
        * so if the selected translation id exists in the downloaded translation ids then we will download the selected translation
        * else we will download the 1st translation id and select that for the user
        * */
        final bool doesPreSelectedIdExists = translationIds
            .any((e) => e["id"] == settingsBloc.state.selectedTranslationId);

        Logger().i(
            "Pre selected id exists: $doesPreSelectedIdExists \n translation iDs: $translationIds \n selected id: ${settingsBloc.state.selectedTranslationId}");

        // if the preselected id does not exist in the downloaded translation ids
        if (doesPreSelectedIdExists == false) {
          Logger().i("iD NOT FOUND");
          // change the selected translation id to the 1st translation id
          settingsBloc.add(SettingsEventChangeTranslation(
              translationId: translationIds[0]["id"] as int));
          // download the translation
          await _downloadFullQuranTranslation(
            emit: emit,
            translationId: translationIds[0]["id"].toString(),
          );
        }
        // else do nothing
        else {
          Logger().i(
              "Pre selected translation id exists in the downloaded translation ids, so only refreshing the data...");
          // download the pre selected translation
          await _downloadFullQuranTranslation(
            emit: emit,
            translationId: settingsBloc.state.selectedTranslationId.toString(),
          );
        }
      }
    }

    // if function is called in retry download event
    if (isRetrying == true) {
      if (state.areTranslationIdsDownloaded == true &&
          state.isTranslationDownloaded == false) {
        await extractionIdAndDownloadTranslation();
      }
    }
    //   if called in download event
    else {
      // getting the 1st translation id
      await extractionIdAndDownloadTranslation();
    }
  }

  // Function to handle Surah Names Metadata download
  Future<void> _downloadSurahNamesMetaData({required emit}) async {
    await InternetDataRepository.getAllSurahsMetaData(
      languageIsoCode: languageBloc.state.selectedLanguage["iso_code"],
      // call backs
      onError: (e) {
        emit(state.copyWith(
          isSurahNamesMetaDataDownloaded: false,
          isError: true,
        ));
        Logger().e(e);
      },
      onSuccess: (List<dynamic> value) {
        emit(state.copyWith(
          surahNamesMetaData: value,
          isSurahNamesMetaDataDownloaded: true,
        ));

        //   update surahNamesState

        surahNamesBloc.add(UpdateSurahNamesMetadataEvent(
          data: value,
        ));
      },
    );
  }

  // Function to handle Quran download
  Future<void> _downloadQuran({required emit}) async {
    emit(state.copyWith(
      message: "Downloading Quran...",
    ));

    await InternetDataRepository.downloadFullQuranArabicScript(
      onProgress: (currentChapter, totalChapters, progressPercentage) {
        emit(state.copyWith(
          message:
              "Downloading chapter $currentChapter of $totalChapters $progressPercentage",
          progressPercentage: progressPercentage,
        ));
      },
      onSuccess: (List<dynamic> value) {
        // Logger().i(value);
      },
      onCompleted: (message) {
        emit(state.copyWith(
          message: message,
          isQuranDownloaded: true,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          message: "Error downloading Quran",
          isError: true,
          isQuranDownloaded: false,
        ));
        Logger().e(e);
      },
    );
  }

  // Function to handle Translation Ids download
  Future<void> _downloadTranslationIds({required emit}) async {
    emit(state.copyWith(
      message: "Downloading translation Ids...",
    ));

    await InternetDataRepository.downloadAvailableTranslationIds(
      onCompleted: (message) {
        emit(state.copyWith(
          message: message,
          areTranslationIdsDownloaded: true,
        ));
        settingsBloc.add(SettingsEventGetAllTranslationIds(
            languageName:
                languageBloc.state.selectedLanguage["name"].toString()));
      },
      onError: (e) {
        emit(state.copyWith(
          message: "Error downloading translation Ids",
          isError: true,
          areTranslationIdsDownloaded: false,
        ));
        Logger().e(e);
      },
    );
  }

  // Function to handle full Quran translation download

  Future<void> _downloadFullQuranTranslation(
      {required emit, required String translationId}) async {
    emit(state.copyWith(
      message: "Downloading full Quran translation...",
    ));

    Logger().i("Downloading Translation with id $translationId");

    await InternetDataRepository.downloadFullQuranTranslation(
      surahNamesMetaData: state.surahNamesMetaData as List<dynamic>,
      translationId: translationId,
      onCompleted: (message) {
        emit(state.copyWith(
          message: message,
          isTranslationDownloaded: true,
          downloadedTranslationIds: [
            ...state.downloadedTranslationIds,
            int.parse(translationId)
          ],
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          message: "Error downloading translation",
          isError: true,
          isTranslationDownloaded: false,
        ));
        Logger().e(e);
      },
    );
  }

  Future<void> _downloadAdditionalFullQuranTranslation(
      {required emit,
      required String translationId,
      required BuildContext context}) async {
    emit(state.copyWith(
      additionalDownloadingId: int.parse(translationId),
    ));
    await InternetDataRepository.downloadFullQuranTranslation(
      surahNamesMetaData: state.surahNamesMetaData as List<dynamic>,
      translationId: translationId,
      onCompleted: (message) {
        emit(state.copyWith(
          downloadedTranslationIds: [
            ...state.downloadedTranslationIds,
            int.parse(translationId)
          ],
          additionalDownloadingId: -1,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Translation downloaded"),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (e) {
        emit(state.copyWith(
          additionalDownloadingId: -1,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error downloading translation"),
            backgroundColor: Colors.red,
          ),
        );
        Logger().e(e);
      },
    );
  }

  // Final emit function to handle emitting the final state based on success or failure
  void _finalEmit({required emit}) {
    if (!state.isQuranDownloaded ||
        !state.areTranslationIdsDownloaded ||
        !state.isTranslationDownloaded ||
        !state.isSurahNamesMetaDataDownloaded ||
        state.isError == true) {
      // Emit error state
      emit(state.copyWith(
        isSnackbarVisible: true,
        message: "Download failed",
        isDownloading: true,
        progressPercentage: state.progressPercentage,
        isError: true,
        isAllDataDownloaded: false,
      ));
    } else {
      // Emit success state
      emit(state.copyWith(
        lastFetchedDate: DateFormat("d MMM yyyy h:m aa").format(DateTime.now()),
        message: "Download completed",
        isSnackbarVisible: false,
        isDownloading: false,
        isError: false,
        isAllDataDownloaded: true,
      ));
    }

    //   ========================= ON DEMAND EVENTS =========================

    // Define the behavior for handling the DownloadAdditionalTranslationEvent
  }

  @override
  DownloaderState? fromJson(Map<String, dynamic> json) {
    return DownloaderState(
      lastFetchedDate: json["lastFetchedDate"],
      surahNamesMetaData: json["surahNamesMetaData"],
      isSurahNamesMetaDataDownloaded: json["isSurahNamesMetaDataDownloaded"],
      isQuranDownloaded: json["isQuranDownloaded"],
      areTranslationIdsDownloaded: json["areTranslationIdsDownloaded"],
      isAllDataDownloaded: json["isAllDataDownloaded"],
      isTranslationDownloaded: json["isTranslationDownloaded"],
      message: json["message"],
      isSnackbarVisible: json["isSnackbarVisible"],
      progressPercentage: json["progressPercentage"],
      isDownloading: json["isDownloading"],
      isError: json["isError"],
      downloadedTranslationIds: json["downloadedTranslationIds"],
    );
  }

  @override
  Map<String, dynamic>? toJson(DownloaderState state) {
    return {
      "lastFetchedDate": state.lastFetchedDate,
      "surahNamesMetaData": state.surahNamesMetaData,
      "isSurahNamesMetaDataDownloaded": state.isSurahNamesMetaDataDownloaded,
      "isQuranDownloaded": state.isQuranDownloaded,
      "areTranslationIdsDownloaded": state.areTranslationIdsDownloaded,
      "isAllDataDownloaded": state.isAllDataDownloaded,
      "isTranslationDownloaded": state.isTranslationDownloaded,
      "message": state.message,
      "isSnackbarVisible": state.isSnackbarVisible,
      "progressPercentage": state.progressPercentage,
      "isDownloading": state.isDownloading,
      "isError": state.isError,
      "downloadedTranslationIds": state.downloadedTranslationIds,
    };
  }
}
