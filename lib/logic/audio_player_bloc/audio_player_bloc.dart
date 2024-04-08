import 'dart:async';

import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/non_segmented_reciters.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/logic/juz_display_bloc/juz_display_bloc.dart';
import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:al_quran_new/logic/surah_names_bloc/surah_names_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../display_type_switcher_bloc/display_type_switcher_bloc.dart';
import '../surah_display_bloc/surah_display_bloc.dart';

part 'audio_player_event.dart';

part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final SurahDisplayBloc surahDisplayBloc;
  final JuzDisplayBloc juzDisplayBloc;
  final DisplayTypeSwitcherBloc displayTypeSwitcherBloc;
  final SurahNamesBloc surahNamesBloc;
  final SettingsBloc settingsBloc;

  // Declare a stream subscription variable
  late StreamSubscription<Duration?> audioPositionSubscription;
  late StreamSubscription<int?> currentAudioIndexStream;

  AudioPlayerBloc(
      {required this.surahDisplayBloc,
      required this.displayTypeSwitcherBloc,
      required this.juzDisplayBloc,
      required this.settingsBloc,
      required this.surahNamesBloc})
      : super(const AudioPlayerState()) {
    // ========== LOADS AUDIO DATA ==========
    on<LoadAudioEvent>((event, emit) async {
      try {
        // ========================== LOADS AUDIO DATA ==========================

        // if audio was playing then reset the values before further loading and playing
        /* important
        * if i dont reset then there is an abnormal behaviour where when juz is played surah is scrolled
        * and vice versa*/
        if (state.isAudioPlaying) {
          emit(
            state.copyWith(
              isAudioPlaying: false,
              currentSurahOrJuzId: "",
              currentAudioIndex: null,
              currentAudioPageIndex: null,
              highlightWordLocation: "",
            ),
          );
          currentAudioIndexStream.cancel();
          audioPositionSubscription.cancel();
        }

        emit(
          state.copyWith(
            reciterId: event.reciterId,
            currentSurahOrJuzId: event.surahOrJuzId,
            quranDisplayType: event.quranDisplayType,
            isError: false,
            isDataLoaded: false,
          ),
        );

        // updating the selected reciter id ( if a new reciter id is selected from the settings reciters list)
        settingsBloc
            .add(UpdateSelectedReciterIdEvent(reciterId: event.reciterId));

        /*
         * if the reciterId is non_seg then the audio link is already provided in the data

         * There are 2 types of recitation data

          * 1. non_segmented ( doesn't  highlight  words while playing )
          *  2. segmented ( highlight words )
         */

        // ========================== LOADS NON SEGMENTED AUDIO DATA ==========================

        Logger().i("Recitation Id ========== ${event.reciterId}");

        if (event.reciterId.contains("non_seg")) {
          switch (event.quranDisplayType) {
            case QuranDisplayType.surah:
              await _surahLoadNonSegmentedAudioData(
                  emit: emit,
                  chapterId: event.surahOrJuzId,
                  reciterId: event.reciterId);
              break;
            case QuranDisplayType.juz:
              await _juzLoadNonSegmentedAudioData(
                  emit: emit,
                  juzId: event.surahOrJuzId,
                  reciterId: event.reciterId);
              break;
          }
        } else {
          // ========================== LOADS SEGMENTED AUDIO DATA ==========================

          switch (event.quranDisplayType) {
            case QuranDisplayType.surah:
              await _surahLoadSegmentedAudioData(
                  reciterId: event.reciterId,
                  chapterId: event.surahOrJuzId,
                  emit: emit);
              break;
            case QuranDisplayType.juz:
              await _juzLoadSegmentedAudioData(
                  reciterId: event.reciterId,
                  juzId: event.surahOrJuzId,
                  emit: emit);
              break;
          }
        }

        // ================================================================================
        // ===============================================================================
        // ============================  DATA LOADING FINISHED  =========================
        // ==============================================================================
        // ===============================================================================

        // === Combines all the verses like a playlist so that there is no delay between verses ====
        final ConcatenatingAudioSource concatenatingAudioSource =
            ConcatenatingAudioSource(
                children: state.audioLinks, useLazyPreparation: true);

        // ========================== SETS AUDIO SOURCE ==========================
        await audioPlayer.setAudioSource(
          concatenatingAudioSource,
          initialIndex: event.playFromVerseIndex ?? 0,
        );

        // ============= Start Playing the audio =============

        if (state.isDataLoaded && event.onlyLoadDontPlay == false) {
          // if specific verse index is provided then play from that verse

          add(PlayAudioEvent());
          add(AudioIndexTrackerEvent());
          add(WordHighlightAndCompletionTrackerEvent());
        }
      } catch (e) {
        Logger().e("Error : $e");
        // emit(state.copyWith(
        //   isError: true,
        //   isDataLoaded: false,
        //   isPlayerVisible: false,
        // ));
      }
    });

    // ========== RECITER SWITCH EVENT ( under settings )==========
    on<SettingsReciterSwitchEvent>((event, emit) async {
      // if audio playing then load the new reciter audio and play it
      if (state.isAudioPlaying) {
        add(LoadAudioEvent(
            quranDisplayType: state.quranDisplayType,
            reciterId: event.reciterId,
            surahOrJuzId: state.currentSurahOrJuzId,
            playFromVerseIndex: state.currentAudioIndex));
      } else if (!state.isAudioPlaying && state.isPlayerVisible) {
        // if audio is not playing but the audio player is visible
        // then it measn that the audio is paused, then  load the new reciter
        // audio from the last payed verse but don't play it.
        return add(LoadAudioEvent(
            quranDisplayType: state.quranDisplayType,
            reciterId: event.reciterId,
            surahOrJuzId: state.currentSurahOrJuzId,
            onlyLoadDontPlay: true));
      } else {
        // if neither the audio player is visible nor the audio is playing then just
        // update the reciter id
        settingsBloc
            .add(UpdateSelectedReciterIdEvent(reciterId: event.reciterId));
      }
    });

    // ========== Seek to specific verse while playing ==========
    on<SeekToSpecificVerseDuringPlayingEvent>((event, emit) async {
      if (state.isDataLoaded) {
        await audioPlayer.seek(Duration.zero, index: event.verseIndex);
      }
    });

    // ========== TRACKS AUDIO INDEX ==========

    on<AudioIndexTrackerEvent>((event, emit) async {
      Logger().i("Tracker started for ${state.quranDisplayType}");

      switch (state.quranDisplayType) {
        case QuranDisplayType.surah:
          await _surahTrackAudioIndex(emit: emit);
          return;
        case QuranDisplayType.juz:
          await _juzTrackAudioIndex(emit: emit);
          return;
      }
    });

    on<WordHighlightAndCompletionTrackerEvent>((event, emit) async {
      await _trackIfCompleted(emit: emit);
    });
    // ========== PLAYS OR PAUSES AUDIO ==========

    on<PlayAudioEvent>((event, emit) async {
      emit(state.copyWith(isAudioPlaying: true));
      await audioPlayer.play();
    });

    on<PauseAudioEvent>((event, emit) async {
      emit(state.copyWith(isAudioPlaying: false));
      await audioPlayer.pause();
    });

    //  uses the the play pause event to play or pause the audio
    on<PlayPauseEvent>((event, emit) async {
      if (state.isDataLoaded) {
        if (state.isAudioPlaying) {
          add(PauseAudioEvent());
        } else {
          add(PlayAudioEvent());
        }
      }
    });

    // ========== SKIPS TO NEXT OR PREVIOUS VERSE ==========
    on<SkipToNextVerseEvent>((event, emit) async {
      if (state.currentAudioIndex != null) {
        final nextIndex = state.currentAudioIndex! + 1;
        if (nextIndex < state.audioLinks.length) {
          await audioPlayer.seek(Duration.zero, index: nextIndex);
        }
      }
    });

    on<SkipToPreviousVerseEvent>((event, emit) async {
      if (state.currentAudioIndex != null) {
        final previousIndex = state.currentAudioIndex! - 1;
        if (previousIndex >= 0) {
          await audioPlayer.seek(Duration.zero, index: previousIndex);
        }
      }
    });

    // TAB CONTROLLERS
    on<SurahGetTabControllerAudioPLayerEvent>((event, emit) async {
      emit(state.copyWith(
        surahTabController: event.surahTabController,
      ));
    });
    on<JuzGetTabControllerAudioPLayerEvent>((event, emit) async {
      emit(state.copyWith(
        juzTabController: event.juzTabController,
      ));
    });

    // ========== SCROLL CONTROLLERS ==========

    on<SurahGetVerseByVerseModeScrollControllerAudioPLayerEvent>(
        (event, emit) async {
      emit(state.copyWith(
        surahVerseByVerseScrollController: event.scrollController,
      ));
    });

    on<SurahGetMushafModeScrollControllerAudioPLayerEvent>((event, emit) async {
      emit(state.copyWith(
        surahMushafItemScrollController: event.scrollController,
      ));
    });
    on<JuzGetVerseByVerseModeScrollControllerAudioPLayerEvent>(
        (event, emit) async {
      emit(state.copyWith(
        juzVerseByVerseScrollController: event.scrollController,
      ));
    });

    on<JuzGetMushafModeScrollControllerAudioPLayerEvent>((event, emit) async {
      emit(state.copyWith(
        juzMushafItemScrollController: event.scrollController,
      ));
    });

    on<StopAudioPlayerEvent>((event, emit) async {
      await audioPlayer.stop();

      await resetValues(emit: emit);
    });

    on<LoopAudioEvent>((event, emit) async {
      switch (event.loopType) {
        case LoopType.off:
          audioPlayer.setLoopMode(LoopMode.off);
          emit(state.copyWith(
            loopType: LoopType.off,
          ));
          break;
        case LoopType.one:
          audioPlayer.setLoopMode(LoopMode.one);
          emit(state.copyWith(
            loopType: LoopType.one,
          ));

          break;
        case LoopType.all:
          audioPlayer.setLoopMode(LoopMode.all);
          emit(state.copyWith(
            loopType: LoopType.all,
          ));
          break;
      }
    });
  }

  // ========== SUPPORTING AUDIO FUNCTIONS ==========
  // ============================================================
  // ============================================================
  // ============================================================
  // ============================================================
  // ============================================================

  // ========== LOADS AUDIO DATA ==========

  // surah load segmented data
  Future<void> _surahLoadSegmentedAudioData(
      {required String reciterId,
      required String chapterId,
      required Emitter<AudioPlayerState> emit}) async {
    Logger().i(
        "juz load segmented data or Surah : $chapterId and reciterId : $reciterId");

    // loading data
    await InternetDataRepository().getRecitationData(
        reciterId: reciterId,
        chapterId: chapterId,
        onCompleted: (recitationDataList) {
          final List<AudioSource> audioLinks = [];
          for (int i = 0; i < recitationDataList.length; i++) {
            // if the reciterId is 12 or 6 then the already the full audio link is provided in the data

            if (reciterId == "12" || reciterId == "6" || reciterId == "11") {
              audioLinks.add(AudioSource.uri(Uri.parse(recitationDataList[i]
                      ["url"]
                  .toString()
                  .replaceAll("//", "https://"))));
            } else {
              audioLinks.add(AudioSource.uri(Uri.parse(
                  "https://verses.quran.com/${recitationDataList[i]["url"]}")));

              // Logger().i("Audio Link : ${recitationDataList[i]["url"]}");
            }
          }

          emit(state.copyWith(
            audioLinks: audioLinks,
            recitationData: recitationDataList,
            isDataLoaded: true,
            isPlayerVisible: true,
            isError: false,
          ));

          return;
        },
        onError: (e) {
          Logger().e("Error : $e");
          emit(state.copyWith(
            isError: true,
            isDataLoaded: false,
            isPlayerVisible: false,
          ));
          return;
        });
  }

  // surah load segmented data
  Future<void> _juzLoadSegmentedAudioData(
      {required String juzId,
      required String reciterId,
      required Emitter<AudioPlayerState> emit}) async {
    Logger().i(
        "juz load segmented data or juzID : $juzId and reciterId : $reciterId");

    final Map<String, String> juzSurahVersesMapping =
        AppVariables.juzMetaData[int.parse(juzId) - 1]["verse_mapping"];

    List<AudioSource> audioLinks = [];
    List<dynamic> recitationDataList = [];

// Create empty lists in recitationDataList equal to the length of juzSurahVersesMapping
//     this helps to sequence the surah according to the verse mapping as fetch it from the api
//     cause the api doesn't return the data in the sequence of the verse mapping
    recitationDataList =
        List.generate(juzSurahVersesMapping.length, (index) => []);

    // loading data

    await Future.wait(juzSurahVersesMapping.entries.map((entry) async {
      final List<String> verses = entry.value.split("-");
      final String surahId = entry.key;
      final int startVerse = int.parse(verses[0]);
      final int endVerse = int.parse(verses[1]);

      Logger().i("entry : $entry");

      await InternetDataRepository().getRecitationData(
          reciterId: reciterId,
          chapterId: surahId,
          onCompleted: (List<dynamic> resultRecitationDataList) {
            //

            final List<dynamic> filteredRecitationDataList =
                resultRecitationDataList.sublist(startVerse - 1, endVerse);

            Logger().i(
                "Filtered Recitation Data List : $filteredRecitationDataList");

            // Extract the keys from the map into a list
            List<String> keys = juzSurahVersesMapping.keys.toList();

// Find the index of the surahId in the keys list
            int index = keys.indexOf(surahId);

            // filling the recitationDataList with the filtered data at their appropriate index
            recitationDataList[index] = (filteredRecitationDataList);
          },
          onError: (e) {
            Logger().e("Error : $e");
            emit(state.copyWith(
              isError: true,
              isDataLoaded: false,
              isPlayerVisible: false,
            ));
            return;
          });
    }));

    Logger().i("Verse mapping : $juzSurahVersesMapping");
    Logger().d("recitation data list : ${recitationDataList.length}");
    Logger().i("Audio Links : ${audioLinks.length}");

    // combining data of all the indexes of recitationDataList
    final combinedRecitationDataList =
        recitationDataList.expand((element) => element).toList();

    // generating the audio links

    for (int i = 0; i < combinedRecitationDataList.length; i++) {
      // if the reciterId is 12 or 6 then the already the full audio link is provided in the data

      if (reciterId == "12" || reciterId == "6" || reciterId == "11") {
        audioLinks.add(AudioSource.uri(Uri.parse(combinedRecitationDataList[i]
                ["url"]
            .toString()
            .replaceAll("//", "https://"))));
      } else {
        audioLinks.add(AudioSource.uri(Uri.parse(
            "https://verses.quran.com/${combinedRecitationDataList[i]["url"]}")));

        // Logger().i("Audio Link : ${recitationDataList[i]["url"]}");
      }
    }

    emit(state.copyWith(
      audioLinks: audioLinks,
      recitationData: combinedRecitationDataList,
      isDataLoaded: true,
      isPlayerVisible: true,
      isError: false,
    ));
  }

  // ======================================================
  // ======================================================
  // ========== LOADS NON SEGMENTED AUDIO DATA ==========
  // ======================================================
  // ======================================================
  Future<void> _surahLoadNonSegmentedAudioData(
      {required Emitter<AudioPlayerState> emit,
      required String chapterId,
      required String reciterId}) async {
    Logger()
        .i(" ================== Non Segmented Recitation ==================");
    //   if the recitation is non segmented then the id will have a pre fix of non_seg ex: non_seg_1

    final int verseCount = surahNamesBloc
        .state.surahNamesMetaData?[int.parse(chapterId) - 1]["verses_count"];

    // Combines the reciters and translations so that i can search the non_seg ids in all of them together rather than doing them separately
    const List<Map<String, String>> combinedNonSegRecitersAndTranslationsList =
        [
      ...NonSegmentedRecitersClass.reciters,
      ...NonSegmentedRecitersClass.translations
    ];
    final List<AudioSource> audioLinks = [];
    for (var reciter in combinedNonSegRecitersAndTranslationsList) {
      if (reciter["id"] == reciterId) {
        for (int i = 1; i <= verseCount; i++) {
          audioLinks.add(AudioSource.uri(Uri.parse(
              "${reciter["url"]}${chapterId.padLeft(3, "0")}${i.toString().padLeft(3, "0")}.mp3")));

          Logger().i(
              "Audio Link : ${reciter["url"]}${chapterId.padLeft(3, "0")}${i.toString().padLeft(3, "0")}.mp3");
        }
      }
    }

    emit(state.copyWith(
      audioLinks: audioLinks,
      // makes the recitation data empty so that the _highlightWordLocation function doesn't run for non segmented recitations
      recitationData: [],
      // make the highlight word location empty so that nothing remains highlighted during the reciter switch
      highlightWordLocation: "",
      isDataLoaded: true,
      isPlayerVisible: true,
      isError: false,
    ));
  }

  // ========== LOADS NON SEGMENTED AUDIO DATA ==========
  Future<void> _juzLoadNonSegmentedAudioData({
    required Emitter<AudioPlayerState> emit,
    required String juzId,
    required String reciterId,
  }) async {
    Logger().i(
        " ================== JUZ Non Segmented Recitation ==================");
    //   if the recitation is non segmented then the id will have a pre fix of non_seg ex: non_seg_1

    // Combines the reciters and translations so that i can search the non_seg ids in all of them together rather than doing them separately
    const List<Map<String, String>>
        combinedNonSegRecitersAndTranslationsDataList = [
      ...NonSegmentedRecitersClass.reciters,
      ...NonSegmentedRecitersClass.translations
    ];
    final List<AudioSource> audioLinks = [];
    for (var reciter in combinedNonSegRecitersAndTranslationsDataList) {
      if (reciter["id"] == reciterId) {
        final Map<String, String> juzSurahVersesMapping =
            AppVariables.juzMetaData[int.parse(juzId) - 1]["verse_mapping"];

        // "verse_mapping": {"1": "1-7", "2": "1-141"},

        juzSurahVersesMapping.forEach((key, value) {
          final List<String> verses = value.split("-");
          final int startVerse = int.parse(verses[0]);
          final int endVerse = int.parse(verses[1]);

          for (int i = startVerse; i <= endVerse; i++) {
            audioLinks.add(AudioSource.uri(Uri.parse(
                "${reciter["url"]}${key.padLeft(3, "0")}${i.toString().padLeft(3, "0")}.mp3")));

            Logger().i(
                "Audio Link : ${reciter["url"]}${key.padLeft(3, "0")}${i.toString().padLeft(3, "0")}.mp3");
          }
        });
      }
    }

    emit(state.copyWith(
      audioLinks: audioLinks,
      // makes the recitation data empty so that the _highlightWordLocation function doesn't run for non segmented recitations
      recitationData: [],
      // make the highlight word location empty so that nothing remains highlighted during the reciter switch
      highlightWordLocation: "",
      isDataLoaded: true,
      isPlayerVisible: true,
      isError: false,
    ));
  }

  // ========== HIGHLIGHTS THE WORD LOCATION ==========
  // is called in the _trackIfCompleted function ( from which it takes the current duration and the index of the current verse)

  Future<void> _highlightWordLocation(
      {required Duration currentDuration,
      required int index,
      required Emitter<AudioPlayerState> emit}) async {
    // if the recitation is non segmented then then [ state.recitationData ] will be null
    // look at loadDataEvent to understand exactly what im saying if you forgot
    if (state.recitationData.isNotEmpty) {
      final durationInMilliseconds = currentDuration.inMilliseconds;
      // Logger().i("Current Duration (milliseconds) : $durationInMilliseconds");

      state.recitationData[index]["segments"].forEach((word) {
        if (word[2] <= durationInMilliseconds &&
            word[3] >= durationInMilliseconds) {
          emit(state.copyWith(
            highlightWordLocation:
                "${state.recitationData[index]["verse_key"]}:${word[1]}",
          ));
        }
      });
    }
  }

  // ========== TRACKS AUDIO INDEX ==========
  // is called in the on<LoadAudioEvent> function ( tracks the current playing verse index of the audio player)
  Future<void> _surahTrackAudioIndex(
      {required Emitter<AudioPlayerState> emit}) async {
    try {
      List pages = surahDisplayBloc.state.surahData!
          .map((e) => e["page_number"])
          .toSet()
          .toList();

      final surahData = surahDisplayBloc.state.surahData;

      Completer<void> completer = Completer<void>();

      currentAudioIndexStream =
          audioPlayer.currentIndexStream.listen((verseIndex) {
        Logger().i("audio Current Index : $verseIndex");
        final pageNumber = surahData?[verseIndex as int]["page_number"];
        final pageIndex = pages.indexWhere((element) => element == pageNumber);
        // Scroll to the playing tab
        if (state.surahTabController != null &&
            state.currentSurahOrJuzId !=
                surahDisplayBloc.state.selectedSurahNumber.toString()) {
          state.surahTabController
              ?.animateTo(114 - int.parse(state.currentSurahOrJuzId));
        }

        // Scroll to the current playing verse
        if (surahDisplayBloc.state.selectedSurahNumber ==
            int.parse(state.currentSurahOrJuzId)) {
          if (state.surahVerseByVerseScrollController != null &&
              displayTypeSwitcherBloc.state.isMushafMode == false) {
            state.surahVerseByVerseScrollController?.scrollTo(
                index: verseIndex as int,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500));
          }

          if (state.surahMushafItemScrollController != null &&
              displayTypeSwitcherBloc.state.isMushafMode) {
            if (pageIndex != state.currentAudioPageIndex) {
              state.surahMushafItemScrollController!.scrollTo(
                  index: pageIndex,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 500));
            }
          }
        }

        emit(state.copyWith(
          currentAudioIndex: verseIndex,
          currentAudioPageIndex: pageIndex,
        ));
      });

      // Complete the future when the subscription is canceled
      currentAudioIndexStream.onDone(() {
        completer.complete();
      });

      // Return a future that doesn't complete until the subscription is canceled
      return completer.future;
    } catch (e) {
      Logger().e("Error : $e");
    }
  }

  // ========== JUZ TRACK AUDIO INDEX ==========
  Future<void> _juzTrackAudioIndex(
      {required Emitter<AudioPlayerState> emit}) async {
    try {
      List pages = juzDisplayBloc.state.juzData!
          .map((e) => e["page_number"])
          .toSet()
          .toList();

      final juzData = juzDisplayBloc.state.juzData;

      Completer<void> completer = Completer<void>();

      currentAudioIndexStream =
          audioPlayer.currentIndexStream.listen((verseIndex) {
        Logger().i(
            "audio Current Index : $verseIndex and JUZ ID : ${state.currentSurahOrJuzId} and actual juz id = ${juzDisplayBloc.state.selectedJuzId}");
        final pageNumber = juzData?[verseIndex as int]["page_number"];
        final pageIndex = pages.indexWhere((element) => element == pageNumber);

        // Scroll to the playing tab
        if (state.juzTabController != null &&
            state.currentSurahOrJuzId !=
                juzDisplayBloc.state.selectedJuzId.toString()) {
          state.juzTabController
              ?.animateTo(30 - int.parse(state.currentSurahOrJuzId));
        }
        // Scroll to the current verse
        if (juzDisplayBloc.state.selectedJuzId ==
            int.parse(state.currentSurahOrJuzId)) {
          if (state.juzVerseByVerseScrollController != null &&
              displayTypeSwitcherBloc.state.isMushafMode == false) {
            state.juzVerseByVerseScrollController?.scrollTo(
                index: verseIndex as int,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500));
          }

          if (state.juzMushafItemScrollController != null &&
              displayTypeSwitcherBloc.state.isMushafMode) {
            if (pageIndex != state.currentAudioPageIndex) {
              Logger().i(
                  "Scrolling to page index : $pageIndex while current page index was ${state.currentAudioIndex}");

              state.juzMushafItemScrollController!.scrollTo(
                  index: pageIndex,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 500));
            }
          }
        }

        emit(state.copyWith(
          currentAudioIndex: verseIndex,
          currentAudioPageIndex: pageIndex,
        ));
      });

      // Complete the future when the subscription is canceled
      currentAudioIndexStream.onDone(() {
        completer.complete();
      });

      // Return a future that doesn't complete until the subscription is canceled
      return completer.future;
    } catch (e) {
      Logger().e("Error : $e");
    }
  }

  // ========== TRACKS IF AUDIO IS COMPLETED ==========
  // tracks the duration and also highlight the word location according to the duration
  Future<void> _trackIfCompleted(
      {required Emitter<AudioPlayerState> emit}) async {
    Completer<void> completer = Completer<void>();

    // Listen for position changes
    audioPositionSubscription = audioPlayer.positionStream.listen((position) {
      final duration = audioPlayer.duration;
      if (state.currentAudioIndex != null) {
        //==========
        // highlight the word location
        //============
        _highlightWordLocation(
            currentDuration: position,
            index: state.currentAudioIndex!,
            emit: emit);
      }
      if (state.currentAudioIndex != null &&
          state.currentAudioIndex == state.audioLinks.length - 1) {
        if (duration != null && position >= duration) {
          Logger().i("Audio Completed");

          audioPlayer.stop();
          resetValues(emit: emit);
        }
      }
    });

    // Complete the future when the subscription is canceled
    audioPositionSubscription.onDone(() {
      completer.complete();
    });

    // Return a future that doesn't complete until the subscription is canceled
    return completer.future;
  }

  // ========== CLOSES THE BLOC ==========
  /*

   This runs currently in only  2 scenarios
   1. when the audio is completed
   2. when the user closes the audio player

   */

  Future<void> resetValues({required Emitter<AudioPlayerState> emit}) async {
    emit(
      state.copyWith(
        isAudioPlaying: false,
        isPlayerVisible: false,
        currentSurahOrJuzId: "",
        currentAudioIndex: null,
        currentAudioPageIndex: null,
        highlightWordLocation: "",
      ),
    );
    currentAudioIndexStream.cancel();
    audioPositionSubscription.cancel();
  }
}
