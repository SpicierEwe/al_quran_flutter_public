part of 'audio_player_bloc.dart';

@immutable
abstract class AudioPlayerEvent {}

/*
  * This is the event is responsible to load the audio from the server
  * if performs the following tasks:
  * if the [playFromVerseIndex] is not null, then it will load & play the audio from that verse
  * if the [playFromVerseIndex] is null, then it will load & play the audio from the beginning of the chapter

 */

class LoadAudioEvent extends AudioPlayerEvent {
  final String reciterId;
  final String surahOrJuzId;

  // final String juzId;

  final bool onlyLoadDontPlay;
  final QuranDisplayType quranDisplayType;

  // this is optional parameter to play from specific verse
  final int? playFromVerseIndex;

  LoadAudioEvent({
    required this.quranDisplayType,
    required this.reciterId,
    required this.surahOrJuzId,
    // required this.juzId,
    this.onlyLoadDontPlay = false,
    this.playFromVerseIndex,
  });
}

// if the player is playing and user clicks on a verse, then the player should seek to that verse
class SeekToSpecificVerseDuringPlayingEvent extends AudioPlayerEvent {
  final int verseIndex;

  SeekToSpecificVerseDuringPlayingEvent({required this.verseIndex});
}

class PlayAudioEvent extends AudioPlayerEvent {
  PlayAudioEvent();
}

class PauseAudioEvent extends AudioPlayerEvent {
  PauseAudioEvent();
}

class PlayPauseEvent extends AudioPlayerEvent {
  final bool forcePlay;

  PlayPauseEvent({this.forcePlay = false});
}

// fired internally in the bloc ( nothing accesses it from the outside )
class AudioIndexTrackerEvent extends AudioPlayerEvent {
  AudioIndexTrackerEvent();
}

class WordHighlightAndCompletionTrackerEvent extends AudioPlayerEvent {
  WordHighlightAndCompletionTrackerEvent();
}

class SkipToNextVerseEvent extends AudioPlayerEvent {
  SkipToNextVerseEvent();
}

class SkipToPreviousVerseEvent extends AudioPlayerEvent {
  SkipToPreviousVerseEvent();
}

// Surah Controllers

// surah tab controller
class SurahGetTabControllerAudioPLayerEvent extends AudioPlayerEvent {
  final TabController surahTabController;

  SurahGetTabControllerAudioPLayerEvent({
    required this.surahTabController,
  });
}

class SurahGetVerseByVerseModeScrollControllerAudioPLayerEvent
    extends AudioPlayerEvent {
  final ItemScrollController scrollController;

  SurahGetVerseByVerseModeScrollControllerAudioPLayerEvent({
    required this.scrollController,
  });
}

class SurahGetMushafModeScrollControllerAudioPLayerEvent
    extends AudioPlayerEvent {
  final ItemScrollController scrollController;

  SurahGetMushafModeScrollControllerAudioPLayerEvent(
      {required this.scrollController});
}

// JUZ Controllers

// juz tab controller
class JuzGetTabControllerAudioPLayerEvent extends AudioPlayerEvent {
  final TabController juzTabController;

  JuzGetTabControllerAudioPLayerEvent({
    required this.juzTabController,
  });
}

class JuzGetVerseByVerseModeScrollControllerAudioPLayerEvent
    extends AudioPlayerEvent {
  final ItemScrollController scrollController;

  JuzGetVerseByVerseModeScrollControllerAudioPLayerEvent(
      {required this.scrollController});
}

class JuzGetMushafModeScrollControllerAudioPLayerEvent
    extends AudioPlayerEvent {
  final ItemScrollController scrollController;

  JuzGetMushafModeScrollControllerAudioPLayerEvent(
      {required this.scrollController});
}
// ==================

class StopAudioPlayerEvent extends AudioPlayerEvent {
  StopAudioPlayerEvent();
}

class SettingsReciterSwitchEvent extends AudioPlayerEvent {
  final String reciterId;

  SettingsReciterSwitchEvent({required this.reciterId});
}
