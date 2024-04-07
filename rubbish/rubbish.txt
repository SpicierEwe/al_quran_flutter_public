import 'dart:convert';
import 'package:al_quran_new/apis/salah_apis.dart';
import 'package:al_quran_new/logic/repositories/local_data_repository.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../apis/quran_data_apis.dart';

/// Callback type for progress updates during data download.
typedef ProgressCallback = void Function(
    int currentChapter, int totalChapters, String progressPercentage);

/// A repository for fetching Quranic data from the internet.
class InternetDataRepository {
  // HTTP client for making requests
  static final _client = http.Client();

  // Total chapter count for Quran
  static const totalChapterCount = 114; //TODO: change to 114 if not 114

  // =================== Quran-related methods ===================

  /// Fetch available languages.
  static Future<void> getAvailableLanguages(
      {Function(List<dynamic>)? onCompleted, Function(String)? onError}) async {
    try {
      final response =
          await _client.get(Uri.parse(QuranDataApis.allAvailableLanguagesApi));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["languages"];

        // Save to local data repository (Hive)
        LocalDataRepository.storeAvailableLanguages(jsonEncode(decodedData));

        if (onCompleted != null) {
          onCompleted(decodedData);
          Logger().i("Downloaded languages returned");
        }
      } else {
        if (onError != null) {
          onError(response.statusCode.toString());
          return;
        }
      }
    } catch (e) {
      print('Error in getAvailableLanguages: $e');
      if (onError != null) {
        onError(e.toString());

        return;
      }
    }
  }

  /// Fetch all surahs.
  ///
  /// [languageIsoCode]: The ISO code for the language. Default is English.
  static Future<void> getAllSurahsMetaData(
      {languageIsoCode,
      Function(List)? onSuccess,
      Function(dynamic)? onError}) async {
    try {
      final response = await _client.get(Uri.parse(
          QuranDataApis.allSurahsNamesMetaDataApi(
              languageIsoCode: languageIsoCode)));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["chapters"];
        print("Downloaded surahs returned");

        // Execute the success callback if provided
        if (onSuccess != null) {
          onSuccess(decodedData);
        }

        return decodedData;
      } else {
        print('Failed to download surahs. Status code: ${response.statusCode}');

        // Execute the error callback if provided
        if (onError != null) {
          onError(
              'Failed to download surahs. Status code: ${response.statusCode}');
        }

        return Future.error(
            'Failed to download surahs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllSurahs: $e');

      // Execute the error callback if provided
      if (onError != null) {
        onError('Error in getAllSurahs: $e');
        return;
      }
    }
  }

  /// Fetch all available translation IDs metadata .
  /// translation ids of all the languages are downloaded together and then later on
  /// are filtered out based on the language selected by the user
  static Future<void> downloadAvailableTranslationIds({
    Function(String)? onCompleted,
    Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(QuranDataApis.allAvailableTranslationIdsApi));

      if (response.statusCode == 200) {
        List<dynamic> decodedData =
            await jsonDecode(response.body)["translations"];

        // Save to local data repository (Hive)
        LocalDataRepository.storeAllAvailableTranslationIds(
            data: jsonEncode(decodedData));

        if (onCompleted != null) {
          onCompleted("Translation Ids downloaded Successfully");
        }
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);

        return;
      }
    }
  }

  /// Fetch Quran scripts for all chapters.
  ///
  /// [onProgress]: Callback to receive progress updates.
  /// [fromChapterId]: The starting chapter ID for downloading.
  static Future<void> downloadFullQuranArabicScript({
    ProgressCallback? onProgress,
    Function(dynamic)? onError,
    Function(List<dynamic>)? onSuccess,
    Function(String)? onCompleted,
  }) async {
    try {
      for (int chapterId = 1; chapterId <= totalChapterCount; chapterId++) {
        String progressPercentage =
            "${(chapterId / totalChapterCount * 100).toInt()}%";
        final response = await _client.get(Uri.parse(
            QuranDataApis.getArabicChapterApi(
                chapterId: chapterId.toString())));

        if (response.statusCode == 200) {
          final List<dynamic> decodedData =
              await jsonDecode(response.body)["verses"];

          // Save to local data repository (Hive)
          LocalDataRepository.storeQuranArabicChapter(
              data: jsonEncode(decodedData), chapterId: chapterId);

          Logger().i("Downloaded chapter $chapterId returned");
          // Notify progress
          if (onProgress != null) {
            onProgress(chapterId, totalChapterCount, progressPercentage);
          }

          // Execute the success callback if provided
          if (onSuccess != null) {
            onSuccess(decodedData);
          }
        } else {
          if (onError != null) {
            onError(
                'Failed to download chapter $chapterId. Status code: ${response.statusCode}');

            return;
          }
        }
      }

      if (onCompleted != null) {
        onCompleted("Quran downloaded Successfully");
      }
    } catch (e) {
      print('Error in downloadFullQuranScript: $e');
      if (onError != null) {
        onError(
            'Failed to download quran Script. Status code: ${e.toString()}');

        return;
      }
    }
  }

  /// Fetch single translation for all chapters.
  ///
  /// [translationId]: The identifier for the translation.
  /// [fromChapterId]: The starting chapter ID for downloading.
  /// [onProgress]: Callback to receive progress updates.
  static downloadSingleTranslation({
    required int translationId,
    int fromChapterId = 1,
    required Null Function(int currentChapter, int totalChapters) onProgress,
  }) async {
    int? errorFromTranslationChapter;

    try {
      for (int chapterId = fromChapterId;
          chapterId <= totalChapterCount;
          chapterId++) {
        final response = await _client.get(Uri.parse(
            QuranDataApis.getSingleChapterTranslationApi(
                translationId: translationId.toString(),
                chapterId: chapterId.toString())));

        if (response.statusCode != 200) {
          errorFromTranslationChapter = chapterId;
          throw Exception(
              'Failed to download translation chapter $chapterId. Status code: ${response.statusCode}');
        } else {
          var decodedData = await jsonDecode(response.body)["translations"];

          // Save to local data repository (Hive)
          LocalDataRepository.storeQuranTranslationChapter(
              data: jsonEncode(decodedData),
              chapterId: chapterId,
              translationId: translationId);

          print("Downloaded translation chapter $chapterId returned");

          // Notify progress
          onProgress(chapterId, totalChapterCount);
        }
      }

      // Successful download of all chapters
      return {
        "errorFromTranslationChapter": null,
        "message": "Translation downloaded",
        "isTranslationDownloaded": true,
      };
    } catch (e) {
      print('Error in downloadSingleTranslation: $e');
      return {
        "errorFromTranslationChapter": errorFromTranslationChapter ?? 1,
        "message": "Failed downloading translation",
        "isTranslationDownloaded": false,
      };
    }
  }

  /// Fetch full Quran translation.
  static Future<void> downloadFullQuranTranslation({
    required String translationId,
    required List<dynamic> surahNamesMetaData,
    required Function(String)? onCompleted,
    Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
          QuranDataApis.getFullQuranTranslationApi(
              translationId: translationId)));

      // Logger().i(
      //     "Translation URL : ${QuranDataApis.getFullQuranTranslationApi(translationId: translationId)}");

      if (response.statusCode == 200) {
        List<dynamic> decodedData =
            await jsonDecode(response.body)["translations"];

        // Logger().i("Meta Data -= $surahNamesMetaData");
        // Logger().i("Meta Data -= ${response.body}");

        List tempChapterVerses = [];
        int lastVerse = 0;
        for (var element in surahNamesMetaData) {
          int verseCount = element["verses_count"];
          // Logger().i("Verse Count === $verseCount");

          tempChapterVerses =
              decodedData.sublist(lastVerse, lastVerse + verseCount);

          // Save to local data repository (Hive)
          LocalDataRepository.storeQuranTranslationChapter(
            data: jsonEncode(tempChapterVerses),
            chapterId: element["id"],
            translationId: int.parse(translationId),
          );

          lastVerse += verseCount;
        }

        // Save to local data repository (Hive)
        // LocalDataRepository.storeFullQuranTranslation(
        //     data: jsonEncode(decodedData));

        if (onCompleted != null) {
          onCompleted("Translation $translationId downloaded Successfully");
        }
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);

        return;
      }
    }
  }

//    ============================ RELATED TO AUDIO PLAYER ============================
//   get all reciters

  Future<void> getAllReciters({
    required Function(List)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    try {
      final response =
          await _client.get(Uri.parse(QuranDataApis.getAllRecitersApi()));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["recitations"];

        if (onCompleted != null) {
          onCompleted(decodedData);
        }

        // Save to local data repository (Hive)
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);

        return;
      }
    }
  }

//   FETCH RECITATION DATA
  Future<void> getRecitationData({
    required String reciterId,
    required String chapterId,
    required Function(List<dynamic>)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
          QuranDataApis.getSegmentedAudioChapterApi(
              chapterId: chapterId, reciterId: reciterId)));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["audio_files"];

        // Logger().i("decodedData : $decodedData");

        if (onCompleted != null) {
          onCompleted(decodedData);
        }

        // Save to local data repository (Hive)
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);

        return;
      }
    }
  }

//   ========================= SALAH REPOSITORIES =================
  static Future<void> getSalahTimes({
    required String latitude,
    required String longitude,
    required Function(dynamic)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    Logger().i("Latitude: $latitude, Longitude: $longitude");
    try {
      final response = await _client.get(Uri.parse(
          SalahApis.salahTimesApi(latitude: latitude, longitude: longitude)));

      if (response.statusCode == 200) {
        final decodedData = await jsonDecode(response.body);

        if (onCompleted != null) {
          onCompleted(decodedData);
        }
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);

        return;
      }
    }
  }

  // GET QIBLA DIRECTION
  static Future<void> getQiblaDirection(
      {required String latitude,
      required String longitude,
      required Function(dynamic)? onCompleted,
      required Function(dynamic)? onError}) async {
    // Logger().i(
    //     SalahApis.qiblaDirectionApi(latitude: latitude, longitude: longitude));
    final response = await _client.get(Uri.parse(
        SalahApis.qiblaDirectionApi(latitude: latitude, longitude: longitude)));

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      if (onCompleted != null) {
        onCompleted(decodedData["data"]["direction"]);
      }
    } else {
      if (onError != null) {
        onError(response.statusCode);
        return;
      }
    }
  }

//   get Surah Info

  static Future<void> getSurahInfo({
    required String surahId,
    required String languageIsoCode,
    required Function(dynamic)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
          QuranDataApis.getSurahInfoApi(
              surahId: surahId, languageIsoCode: languageIsoCode)));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["chapter_info"];

        if (onCompleted != null) {
          onCompleted(decodedData);
        }

        // Save to local data repository (Hive)
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);
        return;
      }
    }
  }

//   get all Tafsir ids of all languages in one go

  Future<void> getAllTafsirIds({
    required Function(List)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(QuranDataApis.getAllTafsirsMetaDataApi()));

      if (response.statusCode == 200) {
        var decodedData = await jsonDecode(response.body)["tafsirs"];

        if (onCompleted != null) {
          onCompleted(decodedData);
        }

        // Save to local data repository (Hive)
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);
        return;
      }
    }
  } //    get tafsir

  static Future<void> getTafsir({
    required String tafsirId,
    required String surahId,
    required String verseId,
    required Function(Map<String, dynamic>)? onCompleted,
    required Function(dynamic)? onError,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
          QuranDataApis.getTafsirForSpecificVerseApi(
              tafsirId: tafsirId, verseId: verseId, chapterId: surahId)));

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedData =
            await jsonDecode(response.body)["tafsir"];

        if (onCompleted != null) {
          onCompleted(decodedData);
        }

        // Save to local data repository (Hive)
      } else {
        if (onError != null) {
          onError(response.statusCode);
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(e);
        return;
      }
    }
  }
}
