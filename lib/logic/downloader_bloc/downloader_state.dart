part of 'downloader_bloc.dart';

/// Immutable class representing the state of the downloader feature.
@immutable
class DownloaderState {
  final String lastFetchedDate;
  final List<dynamic>? surahNamesMetaData;

  final List<int> downloadedTranslationIds;

  final bool isSurahNamesMetaDataDownloaded;

  // General properties

  final String message;

  /// Flag indicating whether the snackbar is visible.
  final bool isSnackbarVisible;

  /// The progress of the download operation (null if not applicable).
  final String? progressPercentage;

  /// Flag indicating whether a download operation is in progress.
  final bool isDownloading;

  /// Flag indicating whether an error occurred.
  final bool isError;

  /// Flag indicating whether all data is downloaded.
  final bool isAllDataDownloaded;

  // Quran-related properties

  /// Flag indicating whether the Quran is downloaded.
  final bool isQuranDownloaded;

  // Translation IDs-related properties

  /// Flag indicating whether translation IDs are downloaded.
  final bool areTranslationIdsDownloaded;

  // Translation-related properties

  /// Flag indicating whether a translation is downloaded.
  final bool isTranslationDownloaded;

  // ========= additional downloading state properties ================
  final int additionalDownloadingId;

  /// Constructor for creating an instance of DownloaderState.
  const DownloaderState({
    this.lastFetchedDate = "-",
    this.surahNamesMetaData,
    this.downloadedTranslationIds = const [],
    this.isSurahNamesMetaDataDownloaded = false,
    // Quran-related properties
    this.isQuranDownloaded = false,
    this.areTranslationIdsDownloaded = false,
    this.isAllDataDownloaded = false,
    this.isTranslationDownloaded = false,
    this.message = "initializing...",

    //
    this.isSnackbarVisible = false,
    this.progressPercentage = "0%",
    this.isDownloading = false,

    // this error is global error if anything goes wrong in the downloader bloc
    this.isError = false,

    //   additional downloading state properties

    this.additionalDownloadingId = -1,
  });

  /// A method to create a new DownloaderState instance with modified properties.
  DownloaderState copyWith({
    String? lastFetchedDate,
    bool? isQuranDownloaded,
    bool? isSnackbarVisible,
    String? progressPercentage,
    bool? isDownloading,
    bool? isError,
    bool? areTranslationIdsDownloaded,
    bool? isErrorInTranslationIdsDownload,
    bool? isTranslationDownloaded,
    bool? isErrorInTranslationDownload,
    bool? isAllDataDownloaded,
    List<dynamic>? surahNamesMetaData,
    bool? isSurahNamesMetaDataDownloaded,
    String? message,
    List<int>? downloadedTranslationIds,

    // additional downloading state properties
    int? additionalDownloadingId,
  }) {
    return DownloaderState(
      // last fetched data
      lastFetchedDate: lastFetchedDate ?? this.lastFetchedDate,
      surahNamesMetaData: surahNamesMetaData ?? this.surahNamesMetaData,
      isQuranDownloaded: isQuranDownloaded ?? this.isQuranDownloaded,
      isSnackbarVisible: isSnackbarVisible ?? this.isSnackbarVisible,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isDownloading: isDownloading ?? this.isDownloading,
      isError: isError ?? this.isError,
      areTranslationIdsDownloaded:
          areTranslationIdsDownloaded ?? this.areTranslationIdsDownloaded,
      isTranslationDownloaded:
          isTranslationDownloaded ?? this.isTranslationDownloaded,

      isAllDataDownloaded: isAllDataDownloaded ?? this.isAllDataDownloaded,
      isSurahNamesMetaDataDownloaded:
          isSurahNamesMetaDataDownloaded ?? this.isSurahNamesMetaDataDownloaded,
      message: message ?? this.message,
      downloadedTranslationIds:
          downloadedTranslationIds ?? this.downloadedTranslationIds,

      // additional downloading state properties

      additionalDownloadingId:
          additionalDownloadingId ?? this.additionalDownloadingId,
    );
  }
}
