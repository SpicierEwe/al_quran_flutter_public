part of 'surah_tracker_bloc.dart';

@immutable
abstract class SurahTrackerEvent {}

class SurahDisplayUpdatePageHizbManzilVerseByVerseModeEvent
    extends SurahTrackerEvent {
  final int scrollPositionIndex;
  final int chapterId;

  SurahDisplayUpdatePageHizbManzilVerseByVerseModeEvent({
    required this.scrollPositionIndex,
    required this.chapterId,
  });
}

//
class SurahDisplayUpdatePageHizbManzilMushafModeEvent
    extends SurahTrackerEvent {
  final int scrollPositionIndex;

  SurahDisplayUpdatePageHizbManzilMushafModeEvent({
    required this.scrollPositionIndex,
  });
}

// JUZ DISPLAY ==================================
class JuzDisplayUpdatePageHizbManzilVerseByVerseModeEvent
    extends SurahTrackerEvent {
  final int scrollPositionIndex;
  final int juzId;

  JuzDisplayUpdatePageHizbManzilVerseByVerseModeEvent({
    required this.scrollPositionIndex,
    required this.juzId,
  });
}

//
class JuzDisplayUpdatePageHizbManzilMushafModeEvent extends SurahTrackerEvent {
  final int scrollPositionIndex;

  JuzDisplayUpdatePageHizbManzilMushafModeEvent({
    required this.scrollPositionIndex,
  });
}

class UpdateHighlightWordEvent extends SurahTrackerEvent {
  final String wordLocation;

  UpdateHighlightWordEvent({
    required this.wordLocation,
  });
}
