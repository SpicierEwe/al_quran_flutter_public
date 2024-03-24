part of 'audio_player_bloc.dart';

@immutable
class AudioPlayerState {
  final QuranDisplayType quranDisplayType;

  /* recitation data holds the data about the recitation of the chapter which help in the
    highlighting the words and while the audio is playing.

    The [recitationData] will be empty if the audio is non-segmented

     */
  final List<dynamic> recitationData;
  final String reciterId;
  final String currentSurahOrJuzId;

  final bool isAudioPlaying;
  final List<AudioSource> audioLinks;
  final String highlightWordLocation;
  final TabController? surahTabController;
  final ItemScrollController? surahVerseByVerseScrollController;
  final ItemScrollController? surahMushafItemScrollController;
  final TabController? juzTabController;
  final ItemScrollController? juzVerseByVerseScrollController;
  final ItemScrollController? juzMushafItemScrollController;
  final bool isPlayerVisible;

  // current audio index
  final int? currentAudioIndex;
  final int? currentAudioPageIndex;
  final bool isDataLoaded;
  final bool isError;

  const AudioPlayerState({
    this.quranDisplayType = QuranDisplayType.surah,
    this.isPlayerVisible = false,
    this.surahTabController,
    this.surahVerseByVerseScrollController,
    this.surahMushafItemScrollController,
    this.juzTabController,
    this.juzVerseByVerseScrollController,
    this.juzMushafItemScrollController,
    this.currentAudioIndex,
    this.currentAudioPageIndex,
    this.highlightWordLocation = "",
    this.isAudioPlaying = false,
    this.reciterId = "7",
    this.currentSurahOrJuzId = "-1",
    this.recitationData = const [],
    this.audioLinks = const [],
    this.isDataLoaded = false,
    this.isError = false,
  });

  AudioPlayerState copyWith({
    QuranDisplayType? quranDisplayType,
    String? reciterId,
    String? currentSurahOrJuzId,
    bool? isAudioPlaying,
    List<dynamic>? recitationData,
    List<AudioSource>? audioLinks,
    bool? isDataLoaded,
    bool? isError,
    int? currentAudioIndex,
    String? highlightWordLocation,
    TabController? surahTabController,
    ItemScrollController? surahVerseByVerseScrollController,
    ItemScrollController? surahMushafItemScrollController,
    TabController? juzTabController,
    ItemScrollController? juzVerseByVerseScrollController,
    ItemScrollController? juzMushafItemScrollController,
    int? currentAudioPageIndex,
    bool? isPlayerVisible,
  }) {
    return AudioPlayerState(
      quranDisplayType: quranDisplayType ?? this.quranDisplayType,
      isPlayerVisible: isPlayerVisible ?? this.isPlayerVisible,
      surahTabController: surahTabController ?? this.surahTabController,
      surahVerseByVerseScrollController: surahVerseByVerseScrollController ??
          this.surahVerseByVerseScrollController,
      surahMushafItemScrollController: surahMushafItemScrollController ??
          this.surahMushafItemScrollController,
      juzTabController: juzTabController ?? this.juzTabController,
      juzVerseByVerseScrollController: juzVerseByVerseScrollController ??
          this.juzVerseByVerseScrollController,
      juzMushafItemScrollController:
          juzMushafItemScrollController ?? this.juzMushafItemScrollController,
      currentAudioIndex: currentAudioIndex ?? this.currentAudioIndex,
      audioLinks: audioLinks ?? this.audioLinks,
      currentSurahOrJuzId: currentSurahOrJuzId ?? this.currentSurahOrJuzId,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      currentAudioPageIndex:
          currentAudioPageIndex ?? this.currentAudioPageIndex,
      recitationData: recitationData ?? this.recitationData,
      reciterId: reciterId ?? this.reciterId,
      isDataLoaded: isDataLoaded ?? this.isDataLoaded,
      isError: isError ?? this.isError,
      highlightWordLocation:
          highlightWordLocation ?? this.highlightWordLocation,
    );
  }
}
