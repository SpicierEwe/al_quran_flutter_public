/// Class containing static methods to generate URLs for fetching Quranic data.
class QuranDataApis {
// Private constructor to prevent instantiation.
  QuranDataApis._();

  /// URL for fetching all available translation IDs.
  static String allAvailableTranslationIdsApi =
      "https://api.quran.com/api/v4/resources/translations";

  /// URL for fetching all available chapters in the Quran.
  static String allAvailableChaptersApi =
      "https://api.quran.com/api/v4/chapters";

  /// URL for fetching all available languages.
  static String allAvailableLanguagesApi =
      "https://api.quran.com/api/v4/resources/languages";

  /// URL for fetching all chapters (surahs) of the Quran.
  ///
  /// The [languageIsoCode] parameter specifies the language for which the surahs
  /// are requested. The default language is English.
  static String allSurahsNamesMetaDataApi({languageIsoCode = "en"}) {
    return "https://api.quran.com/api/v4/chapters?language=$languageIsoCode";
  }

  /// URL for fetching a specific chapter (surah) of the Quran.
  ///
  /// The [chapterId] parameter specifies the ID of the chapter to be fetched.
  static String getArabicChapterApi({required String chapterId}) {
    // return "https://api.quran.com/api/qdc/verses/by_chapter/$chapterId?words=true&fields=qpc_uthmani_hafs,text_qpc_nastaleeq,,code_v2&word_fields=verse_key%2Cverse_id%2Cpage_number%2Clocation%2Cqpc_uthmani_hafs%2Ctext_qpc_nastaleeq%2Cindopak_nastaleeq&per_page=all";

    return "https://api.quran.com/api/qdc/verses/by_chapter/$chapterId?words=true&fields=&word_fields=verse_key%2Cverse_id%2Cpage_number%2Clocation%2Cqpc_uthmani_hafs%2Ctext_qpc_nastaleeq%2Ccode_v2&per_page=all";
  }

  /// URL for fetching a single translation of a specific chapter.
  ///
  /// The [translationId] parameter specifies the ID of the translation, and
  /// [chapterId] specifies the ID of the chapter for which the translation is requested.
  static String getSingleChapterTranslationApi(
          {required String translationId, required String chapterId}) =>
      "https://api.quran.com/api/v4/quran/translations/$translationId?chapter_number=$chapterId";

  /// URL for fetching entire quran translation of a specific translation ID.
  ///
  /// The [translationId] parameter specifies the ID of the translation, and
  /// [juzId] specifies the ID of the chapter for which the translation is requested.
  static String getFullQuranTranslationApi({required String translationId}) =>
      "https://api.quran.com/api/v4/quran/translations/$translationId";

//   ================================================ AUDIO =================================================
  static String getAllRecitersApi() =>
      "https://api.quran.com/api/v4/resources/recitations";

  static String getSegmentedAudioChapterApi(
          {required String chapterId, required String reciterId}) =>
      "https://api.quran.com/api/v4/quran/recitations/$reciterId?fields=segments&chapter_number=$chapterId";

//   Tajweed word images api
/*

* the api has 2 links for the images
*
* 1. for the words
* 2. for the verse end symbol

* so the the last word in the verse will have the verse end symbol, thus we check if the word number is last so we return
* the verse end symbol link

*/

  static String getTajweedWordImagesApi(
      {required int surahId,
      required int verseNumber,
      required int wordNumber,
      required wordsLength}) {
    return wordNumber < wordsLength
        ? "https://static.qurancdn.com/images/w/rq-color/$surahId/$verseNumber/$wordNumber.png?v=1"
        : "https://static.qurancdn.com/images/w/common/$verseNumber.png?v=1";
  }

//   =================================== tafsir API =====================================
//   ========= SINGLE TAFSIR API NOT WORKING, so not implemented tafsir yet============
  static String getAllTafsirsMetaData() =>
      "https://api.quran.com/api/v4/resources/tafsirs";

  static String getTafsirForSpecificVerseApi(
      {required String tafsirId,
      required String chapterId,
      required String verseId}) {
    return "https://api.quran.com/api/v4/tafsirs/$tafsirId?chapter_number=$chapterId&verse_key=$verseId";
  }
}
