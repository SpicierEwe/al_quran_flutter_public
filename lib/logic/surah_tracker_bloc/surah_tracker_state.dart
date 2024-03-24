part of 'surah_tracker_bloc.dart';

@immutable
class SurahTrackerState {
  final List pageHizbManzilData;
  final int? verseByVerseScrolledVerseIndex;
  final int? mushafModeScrolledPageIndex;
  final int? chapterId;

  final String highlightWord;

  // for juz ======
  final int? juzId;

  const SurahTrackerState({
    this.chapterId,
    this.pageHizbManzilData = const [0, 0, 0],
    this.verseByVerseScrolledVerseIndex,
    this.mushafModeScrolledPageIndex,
    this.highlightWord = "",
    this.juzId,
  });

  SurahTrackerState copyWith({
    List? pageHizbManzilData,
    int? verseByVerseScrolledVerseIndex,
    int? mushafModeScrolledPageIndex,
    bool? isMushafMode,
    String? highlightWord,
    int? chapterId,
    int? readingScrollPositionIndex,
    int? juzId,
  }) {
    return SurahTrackerState(
      mushafModeScrolledPageIndex:
          mushafModeScrolledPageIndex ?? this.mushafModeScrolledPageIndex,
      pageHizbManzilData: pageHizbManzilData ?? this.pageHizbManzilData,
      verseByVerseScrolledVerseIndex:
          verseByVerseScrolledVerseIndex ?? this.verseByVerseScrolledVerseIndex,
      highlightWord: highlightWord ?? this.highlightWord,
      chapterId: chapterId ?? this.chapterId,
      juzId: juzId ?? this.juzId,
    );
  }
}
