part of 'settings_bloc.dart';

@immutable
class SettingsState {
  final int selectedQuranScriptIndex;
  final String selectedQuranScriptType;

  //
  final List<dynamic>? translationIds;

  final List allRecitersList;

  final int selectedTranslationId;

  final double translationFontSize;
  final double quranTextFontSize;
  final double quranTextWordSpacing;

  // reciterId
  final String selectedReciterId;

  // translation
  final bool showTransliteration;

  const SettingsState({
    this.selectedQuranScriptIndex = 0,
    this.selectedTranslationId = 131,
    this.selectedQuranScriptType = "uthmani",
    this.selectedReciterId = "7",
    this.allRecitersList = const [],
    this.translationFontSize = 13,
    this.quranTextFontSize = 21,
    this.quranTextWordSpacing = 0,
    this.translationIds,
    this.showTransliteration = false,
  });

  SettingsState copyWith({
    int? selectedQuranScriptIndex,
    String? selectedQuranScriptType,
    int? selectedTranslationId,
    List<dynamic>? translationIds,
    double? translationFontSize,
    double? quranTextFontSize,
    double? quranTextWordSpacing,

    // reciterId
    String? selectedReciterId,
    List? allRecitersList,

    //

    bool? showTransliteration,
  }) {
    return SettingsState(
      selectedQuranScriptIndex:
          selectedQuranScriptIndex ?? this.selectedQuranScriptIndex,
      selectedTranslationId:
          selectedTranslationId ?? this.selectedTranslationId,
      selectedQuranScriptType:
          selectedQuranScriptType ?? this.selectedQuranScriptType,
      translationIds: translationIds ?? this.translationIds,
      // reciterId
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      allRecitersList: allRecitersList ?? this.allRecitersList,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      quranTextFontSize: quranTextFontSize ?? this.quranTextFontSize,
      quranTextWordSpacing: quranTextWordSpacing ?? this.quranTextWordSpacing,
      showTransliteration: showTransliteration ?? this.showTransliteration,
    );
  }
}
