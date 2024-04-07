part of 'tafsir_bloc.dart';

class TafsirState {
  final List<dynamic>? allTafsirIdsMetaData;
  final List<dynamic>? languageSpecificTafsirIdsMetaData;
  final Map<String, dynamic>? tafsirData;
  final bool isError;

  TafsirState({
    this.allTafsirIdsMetaData,
    this.languageSpecificTafsirIdsMetaData,
    this.tafsirData,
    this.isError = false,
  });

  TafsirState copyWith({
    List<dynamic>? allTafsirIdsMetaData,
    List<dynamic>? languageSpecificTafsirIdsMetaData,
    int? selectedTafsirId,
    Map<String, dynamic>? tafsirData,
    bool isError = false,
  }) {
    return TafsirState(
      allTafsirIdsMetaData: allTafsirIdsMetaData ?? this.allTafsirIdsMetaData,
      languageSpecificTafsirIdsMetaData: languageSpecificTafsirIdsMetaData ??
          this.languageSpecificTafsirIdsMetaData,
      tafsirData: tafsirData ?? this.tafsirData,
      isError: isError,
    );
  }
}
