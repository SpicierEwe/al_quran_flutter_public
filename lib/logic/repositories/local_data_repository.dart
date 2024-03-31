import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

/// A repository class for managing local data storage using Hive in Dart.
class LocalDataRepository {
  /// Private constructor to prevent instantiation.
  LocalDataRepository._();

  /// The name of the Hive box used for local storage.
  static const boxName = "myBox";

  /// Key for storing and retrieving available languages data.
  static const availableLanguagesKey = "available_languages";
  static const allTranslationIdsKey = "all_translation_ids";

  /// The Hive box instance for local storage.
  static var box = Hive.box('myBox');

  // ============== Storing Data Locally  =================

  /// Stores available languages data locally.
  ///
  /// [data]: The JSON-encoded string representing available languages.
  static void storeAvailableLanguages(String data) {
    box.put(availableLanguagesKey, data);
  }

  /// Stores Arabic chapters of the Quran locally.
  ///
  /// [data]: The JSON-encoded string representing Quran Arabic chapter data.
  /// [chapterId]: The identifier for the Quran chapter.
  static void storeQuranArabicChapter(
      {required String data, required int chapterId}) {
    box.put(chapterId, data);
    print("Saved: Quran Arabic Chapter $chapterId");
  }

  /// Stores all available translation IDs locally.
  ///
  /// [data]: The JSON-encoded string representing all translation IDs.
  static void storeAllAvailableTranslationIds({required String data}) {
    box.put(allTranslationIdsKey, data);
  }

  /// Stores translation chapters of the Quran locally.
  ///
  /// [data]: The JSON-encoded string representing Quran translation chapter data.
  /// [chapterId]: The identifier for the Quran chapter.
  /// [translationId]: The identifier for the translation.
  static void storeQuranTranslationChapter(
      {required String data,
      required int chapterId,
      required int translationId}) {
    box.put("${translationId}_$chapterId", data);
    Logger().i(
        "Saved: Quran Translation Chapter $chapterId for Translation $translationId");
  }

  // ============== Fetching Stored Data  =================

  /// Retrieves the stored available languages data.
  ///
  /// Returns a list of available languages, or null if not found.
  static List? getStoredAvailableLanguages() {
    final data = box.get(availableLanguagesKey);
    if (data != null) {
      return jsonDecode(data) as List;
    } else {
      return null;
    }
  }

  /// Retrieves the stored Arabic chapters of the Quran data.
  ///
  /// [chapterId]: The identifier for the Quran chapter.
  /// Returns a list of Quran Arabic chapter data, or null if not found.
  static List? getStoredQuranArabicChapter({required int chapterId}) {
    final data = box.get(chapterId);
    if (data != null) {
      // Logger().i(chapterId);
      // Logger().i(data);
      return jsonDecode(data) as List;
    } else {
      return null;
    }
  }

  /// Retrieves the stored translation chapters of the Quran data.
  ///
  /// [chapterId]: The identifier for the Quran chapter.
  /// Returns a list of Quran Arabic chapter data, or null if not found.
  static List? getStoredQuranChapterTranslation(
      {required int translationId, required int chapterId}) {
    final data = box.get("${translationId}_$chapterId");
    // Logger().i(data + "${translationId}_$chapterId");
    Logger().i("${translationId}_$chapterId");
    if (data != null) {
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  /// Retrieves the stored translation ids of the Quran data.
  static List<Map<String, dynamic>> getStoredTranslationIds(
      {required String languageName}) {
    final data = box.get(allTranslationIdsKey);

    if (data != null) {
      final allIds = jsonDecode(data);
      final List<Map<String, dynamic>> filteredIds = [];

      for (var id in allIds) {
        if (id["language_name"] == languageName.toString().toLowerCase()) {
          filteredIds.add(id);
        }
      }
      return filteredIds;
    } else {
      return [];
    }
  }

//   retrieve stored chapter info

  static void getStoredSurahInfo({
    required String surahId,
    required String languageIsoCode,
    required Function(dynamic)? onRetrieved,
    required Function(dynamic)? dataNotFound,
  }) {
    final data = box.get("info_${surahId}_$languageIsoCode");
    if (data != null) {
      if (onRetrieved != null) {
        onRetrieved(jsonDecode(data));
      }
    } else {
      if (dataNotFound != null) {
        dataNotFound("Data not found");
      }
    }
  }

// ============== Clearing Stored Data  =================
}
