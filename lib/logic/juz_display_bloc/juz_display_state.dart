part of 'juz_display_bloc.dart';

@immutable
class JuzDisplayState {
  final int? selectedJuzId;
  final List? juzData;
  final List? juzTranslationData;

  const JuzDisplayState({
    this.selectedJuzId,
    this.juzData,
    this.juzTranslationData,
  });

  JuzDisplayState copyWith({
    int? selectedJuzId,
    List? juzData,
    List? juzTranslationData,
  }) {
    return JuzDisplayState(
      selectedJuzId: selectedJuzId ?? this.selectedJuzId,
      juzData: juzData ?? this.juzData,
      juzTranslationData: juzTranslationData ?? this.juzTranslationData,
    );
  }
}
