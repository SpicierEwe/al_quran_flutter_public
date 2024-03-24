part of 'juz_display_bloc.dart';

@immutable
abstract class JuzDisplayEvent {}

class UpdateSelectedJuzId extends JuzDisplayEvent {
  final int selectedJuzId;

  UpdateSelectedJuzId({required this.selectedJuzId});
}

class DisplayJuzEvent extends JuzDisplayEvent {
  final int selectedJuzNumber;
  final int selectedTranslationId;

  DisplayJuzEvent(
      {required this.selectedTranslationId, required this.selectedJuzNumber});
}
