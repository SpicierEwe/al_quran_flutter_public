part of 'surah_display_bloc.dart';

@immutable
abstract class SurahDisplayEvent {}

class DisplaySurahEvent extends SurahDisplayEvent {
  final int selectedSurahNumber;
  final int selectedTranslationId;

  DisplaySurahEvent(
      {required this.selectedTranslationId, required this.selectedSurahNumber});
}

class SelectedSurahNumberEvent extends SurahDisplayEvent {
  final int? selectedSurahNumber;

  SelectedSurahNumberEvent({required this.selectedSurahNumber});
}
