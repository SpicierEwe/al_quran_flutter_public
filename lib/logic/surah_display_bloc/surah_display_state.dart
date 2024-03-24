part of 'surah_display_bloc.dart';

@immutable
class SurahDisplayState {
  // selectedSurahNumber is used to store the selected surah number
  final int? selectedSurahNumber;
  final List? surahData;
  final List? chapterTranslationData;

  const SurahDisplayState({
    this.selectedSurahNumber,
    this.surahData,
    this.chapterTranslationData,
  });

  // copyWith is used to copy the state and change only the required properties
  SurahDisplayState copyWith({
    int? selectedSurahNumber,
    List? surahData,
    List? chapterTranslationData,
  }) {
    return SurahDisplayState(
      selectedSurahNumber: selectedSurahNumber ?? this.selectedSurahNumber,
      surahData: surahData ?? this.surahData,
      chapterTranslationData:
          chapterTranslationData ?? this.chapterTranslationData,
    );
  }
}
