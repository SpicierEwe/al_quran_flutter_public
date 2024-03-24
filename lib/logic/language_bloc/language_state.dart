part of 'language_bloc.dart';

@immutable
class LanguageState {
  final List? allLanguages;
  final bool areLanguagesDownloaded;
  final bool isError;
  final Map<String, dynamic> selectedLanguage;

  final String searchQuery;
  final List searchResults;

  const LanguageState(
      {this.areLanguagesDownloaded = false,
      this.isError = false,
      this.allLanguages,
      this.searchQuery = "",
      this.selectedLanguage = AppVariables.defaultSelectedLanguage,
      this.searchResults = const []}); // initial state

  LanguageState copyWith({
    List? allLanguages,
    bool? areLanguagesDownloaded,
    Map<String, dynamic>? selectedLanguage,
    String? searchQuery,
    List? searchResults,
    bool? isError,
  }) {
    return LanguageState(
      allLanguages: allLanguages ?? this.allLanguages,
      areLanguagesDownloaded:
          areLanguagesDownloaded ?? this.areLanguagesDownloaded,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isError: isError ?? this.isError,
    );
  }
}
