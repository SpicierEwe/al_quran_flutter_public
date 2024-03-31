part of 'surah_info_bloc.dart';

class SurahInfoState {
  // holds the information about the surah
  final Map<String, dynamic>? surahInfo;
  final bool isError;

  // constructor for the SurahInfoState
  const SurahInfoState({
    this.surahInfo,
    this.isError = false,
  });

//   Copy Constructor

  SurahInfoState copyWith({
    Map<String, dynamic>? surahInfo,
    bool? isError,
  }) {
    return SurahInfoState(
      surahInfo: surahInfo ?? this.surahInfo,
      isError: isError ?? this.isError,
    );
  }
}
