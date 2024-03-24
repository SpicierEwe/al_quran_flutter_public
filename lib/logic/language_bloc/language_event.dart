part of 'language_bloc.dart';

@immutable
abstract class LanguageEvent {}

class FetchAvailableLanguagesEvent extends LanguageEvent {}

class SelectedLanguageEvent extends LanguageEvent {
  final Map<String, dynamic> selectedLanguage;

  SelectedLanguageEvent({required this.selectedLanguage});
}

class SearchLanguageEvent extends LanguageEvent {
  final String searchQuery;

  SearchLanguageEvent({required this.searchQuery});
}

class RetryLanguagesDownloadEvent extends LanguageEvent {}
