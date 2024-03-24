part of 'surah_names_bloc.dart';

@immutable
class SurahNamesState {
  final List? surahNamesMetaData;
  final Map<String, dynamic>? selectedSurah;

  const SurahNamesState({
    this.surahNamesMetaData,
    this.selectedSurah,
  });

  SurahNamesState copyWith({
    List? surahNamesMetaData,
    Map<String, dynamic>? selectedSurah,
  }) {
    return SurahNamesState(
      surahNamesMetaData: surahNamesMetaData ?? this.surahNamesMetaData,
      selectedSurah: selectedSurah ?? this.selectedSurah,
    );
  }
}

// select surah map looks like this
// {
// "id": 1,
// "revelation_place": "makkah",
// "revelation_order": 5,
// "bismillah_pre": false,
// "name_simple": "Al-Fatihah",
// "name_complex": "Al-Fātiĥah",
// "name_arabic": "الفاتحة",
// "verses_count": 7,
// "pages": [
// 1,
// 1
// ],
// "translated_name": {
// "language_name": "russian",
// "name": "Открывающая Коран"
// }
// },
