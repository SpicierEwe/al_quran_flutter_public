import 'dart:ui';

import 'package:al_quran_new/core/constants/enums.dart';
import 'package:al_quran_new/core/constants/non_segmented_reciters.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/core/utils/utils.dart';
import 'package:al_quran_new/logic/audio_bottom_bar_bloc/audio_bottom_bar_bloc.dart';
import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sizer/sizer.dart';

import '../../logic/audio_player_bloc/audio_player_bloc.dart';

enum AudioSettingsOptions { repeat, reciter, translations }

class AudioBottomBarWidget extends StatefulWidget {
  final Widget child;

  const AudioBottomBarWidget({super.key, required this.child});

  @override
  State<AudioBottomBarWidget> createState() => _AudioBottomBarWidgetState();
}

class _AudioBottomBarWidgetState extends State<AudioBottomBarWidget> {
  bool showAudioSettingsOverlayBox = false;
  AudioSettingsOptions selectedAudioSubSettings = AudioSettingsOptions.repeat;

  @override
  void initState() {
    super.initState();

    context.read<AudioBottomBarBloc>().add(GetAllRecitersEvent());
  }

  _updateAudioSettings(AudioSettingsOptions newSelectedAudioSubSettings) {
    setState(() {
      selectedAudioSubSettings = newSelectedAudioSubSettings;
    });
  }

  _closeAudioSettingsOverlayBox() {
    setState(() {
      showAudioSettingsOverlayBox = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color selectedColor = AppVariables.companyColor.withOpacity(.35);
    const double iconSize = 29;
    const double smallIconSize = 21;

    const List<Map<String, dynamic>> repeatOptionsList = [
      {
        "icon": Icons.repeat_rounded,
        "text": "OFF",
        "loopType": LoopType.off,
      },
      {
        "icon": Icons.repeat_one_rounded,
        "text": "ONE",
        "loopType": LoopType.one,
      },
      {
        "icon": Icons.repeat_on,
        "text": "ALL",
        "loopType": LoopType.all,
      }
    ];

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          bloc: BlocProvider.of<AudioPlayerBloc>(context),
          builder: (context, audioPlayerState) {
            return BlocBuilder<AudioBottomBarBloc, AudioBottomBarState>(
              bloc: BlocProvider.of<AudioBottomBarBloc>(context),
              builder: (context, state) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: widget.child,
                        ),
                        if (audioPlayerState.isPlayerVisible)
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaY: 5,
                                      sigmaX: 3,
                                      tileMode: TileMode.mirror),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade200
                                            .withOpacity(.1),
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.blueGrey
                                                .withOpacity(.35),
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.settings_rounded,
                                            ),
                                            iconSize: 25,
                                            onPressed: () {
                                              setState(() {
                                                showAudioSettingsOverlayBox =
                                                    !showAudioSettingsOverlayBox;
                                              });
                                              // BlocProvider.of<AudioBloc>(context).add(AudioPlayEvent('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
                                            },
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons
                                                      .skip_previous_rounded),
                                                  iconSize: iconSize,
                                                  onPressed: () {
                                                    context
                                                        .read<AudioPlayerBloc>()
                                                        .add(
                                                            SkipToPreviousVerseEvent());
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),

                                                // Play Pause Button ==============================
                                                IconButton(
                                                  icon: audioPlayerState
                                                          .isAudioPlaying
                                                      ? const Icon(
                                                          Icons.pause_rounded)
                                                      : const Icon(Icons
                                                          .play_arrow_rounded),
                                                  iconSize: iconSize,
                                                  onPressed: () {
                                                    BlocProvider.of<
                                                                AudioPlayerBloc>(
                                                            context)
                                                        .add(PlayPauseEvent());
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.skip_next_rounded),
                                                  iconSize: iconSize,
                                                  onPressed: () {
                                                    context
                                                        .read<AudioPlayerBloc>()
                                                        .add(
                                                            SkipToNextVerseEvent());
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.stop_rounded),
                                            iconSize: iconSize,
                                            onPressed: () {
                                              // BlocProvider.of<AudioBloc>(context).add(AudioStopEvent());
                                              context
                                                  .read<AudioPlayerBloc>()
                                                  .add(StopAudioPlayerEvent());
                                            },
                                          ),
                                        ],
                                      )),
                                ),
                              )),
                      ],
                    ),

                    // ================== Audio Settings Overlay Box ==============================
                    if (showAudioSettingsOverlayBox &&
                        audioPlayerState.isPlayerVisible)
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _closeAudioSettingsOverlayBox();
                            },
                            child: Container(
                              height: 100.h,
                              width: 100.w,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                margin: EdgeInsets.only(bottom: 55, left: 1.w),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Theme.of(context).primaryColor.withOpacity(0.5),
                                  //     spreadRadius: 1,
                                  //     blurRadius: 5,
                                  //     offset: const Offset(
                                  //         0, 3), // changes position of shadow
                                  //   ),
                                  // ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 40.h,
                                width: 70.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: AppVariables.brandColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            )),
                                        child: Row(
                                          children: [
                                            Container(
                                              color: selectedAudioSubSettings ==
                                                      AudioSettingsOptions
                                                          .repeat
                                                  ? Colors.white
                                                  : AppVariables.brandColor,
                                              child: IconButton(
                                                onPressed: () {
                                                  _updateAudioSettings(
                                                      AudioSettingsOptions
                                                          .repeat);
                                                },
                                                icon: customIcon(
                                                    smallIconSize:
                                                        smallIconSize,
                                                    iconName: const Icon(
                                                        Icons.repeat_rounded),
                                                    audioSettingsOption:
                                                        AudioSettingsOptions
                                                            .repeat),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                            Container(
                                              color: selectedAudioSubSettings ==
                                                      AudioSettingsOptions
                                                          .reciter
                                                  ? Colors.white
                                                  : AppVariables.brandColor,
                                              child: IconButton(
                                                onPressed: () {
                                                  _updateAudioSettings(
                                                      AudioSettingsOptions
                                                          .reciter);
                                                },
                                                icon: customIcon(
                                                    smallIconSize:
                                                        smallIconSize,
                                                    iconName: const Icon(Icons
                                                        .volume_up_rounded),
                                                    audioSettingsOption:
                                                        AudioSettingsOptions
                                                            .reciter),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                            Container(
                                              color: selectedAudioSubSettings ==
                                                      AudioSettingsOptions
                                                          .translations
                                                  ? Colors.white
                                                  : AppVariables.brandColor,
                                              child: IconButton(
                                                onPressed: () {
                                                  _updateAudioSettings(
                                                      AudioSettingsOptions
                                                          .translations);
                                                },
                                                icon: customIcon(
                                                    smallIconSize:
                                                        smallIconSize,
                                                    iconName: const Icon(Icons
                                                        .translate_rounded),
                                                    audioSettingsOption:
                                                        AudioSettingsOptions
                                                            .translations),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // boddy

                                      // ================== Audio Settings Sub Options ==============================

                                      if (selectedAudioSubSettings ==
                                          AudioSettingsOptions.repeat)
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 1.w,
                                              vertical: 2.h,
                                            ),
                                            child: Column(
                                              children: [
                                                // const Text('Reciters'),
                                                Wrap(
                                                  spacing: 2.w,
                                                  children: List.generate(
                                                    repeatOptionsList.length,
                                                    (index) {
                                                      bool isSelected =
                                                          audioPlayerState
                                                                  .loopType ==
                                                              repeatOptionsList[
                                                                      index]
                                                                  ["loopType"];
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 1.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: isSelected
                                                              ? [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        1,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            3),
                                                                    // changes position of shadow
                                                                  ),
                                                                ]
                                                              : null,
                                                          color: audioPlayerState
                                                                      .loopType ==
                                                                  repeatOptionsList[
                                                                          index]
                                                                      [
                                                                      "loopType"]
                                                              ? AppVariables
                                                                  .companyColorGold
                                                                  .withOpacity(
                                                                      .7)
                                                              : bgColor,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                repeatOptionsList[
                                                                        index]
                                                                    ["icon"],
                                                              ),
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                        AudioPlayerBloc>()
                                                                    .add(LoopAudioEvent(
                                                                        loopType:
                                                                            repeatOptionsList[index]["loopType"]));
                                                              },
                                                            ),
                                                            Text(
                                                              repeatOptionsList[
                                                                      index]
                                                                  ["text"],
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),

                                      if (selectedAudioSubSettings ==
                                          AudioSettingsOptions.reciter)
                                        Expanded(
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount:
                                                  state.allRecitersList.length,
                                              itemBuilder: (context, index) {
                                                return TextButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  0),
                                                        ),
                                                      ),
                                                    ),
                                                    // backgroundColor:
                                                    //     MaterialStateProperty.all<
                                                    //             Color>(
                                                    //         selectedAudioSubSettings ==
                                                    //                 AudioSettingsOptions
                                                    //                     .reciter
                                                    //             ? Colors.white
                                                    //             : Colors
                                                    //                 .amberAccent),
                                                  ),
                                                  onPressed: () {
                                                    // _closeAudioSettingsOverlayBox();

                                                    String reciterId = state
                                                        .allRecitersList[index]
                                                            ["id"]
                                                        .toString();

                                                    // ----
                                                    updateReciterAndLoadAudio(
                                                        id: reciterId,
                                                        index: index,
                                                        audioPlayerState:
                                                            audioPlayerState);
                                                  },
                                                  child: ListTile(
                                                    enableFeedback: true,
                                                    tileColor: settingsState
                                                                .selectedReciterId ==
                                                            state
                                                                .allRecitersList[
                                                                    index]["id"]
                                                                .toString()
                                                        ? selectedColor
                                                        : bgColor,

                                                    leading: CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: !state
                                                              .allRecitersList[
                                                                  index]["id"]
                                                              .toString()
                                                              .contains(
                                                                  "non_seg")
                                                          ? AssetImage(
                                                              'assets/images/reciters/${state.allRecitersList[index]["reciter_name"].replaceAll(" ", "_")}.png')
                                                          : AssetImage(
                                                              'assets/images/reciters/${state.allRecitersList[index]["reciter_name"].replaceAll(" ", "_")}.png'),
                                                    ),

                                                    title: Text(
                                                        state.allRecitersList[
                                                                index]
                                                            ["reciter_name"],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                    subtitle: Row(
                                                      children: [
                                                        if (state.allRecitersList[
                                                                    index]
                                                                ["style"] !=
                                                            null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5),
                                                            child: Text(
                                                              state.allRecitersList[
                                                                      index]
                                                                  ["style"],
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ),
                                                        if (!state
                                                            .allRecitersList[
                                                                index]["id"]
                                                            .toString()
                                                            .contains(
                                                                "non_seg"))
                                                          buildHighlightContainer(
                                                              isHighlighted:
                                                                  true,
                                                              context: context),
                                                        if (state
                                                            .allRecitersList[
                                                                index]["id"]
                                                            .toString()
                                                            .contains(
                                                                "non_seg"))
                                                          buildHighlightContainer(
                                                              isHighlighted:
                                                                  false,
                                                              context: context),
                                                      ],
                                                    ),

                                                    // Add any other properties you need for the ListTile
                                                  ),
                                                );
                                              }),
                                        ),

                                      // -------------------- Translations reciters --------------------
                                      if (selectedAudioSubSettings ==
                                          AudioSettingsOptions.translations)
                                        Expanded(
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount:
                                                  NonSegmentedRecitersClass
                                                      .translations.length,
                                              itemBuilder: (context, index) {
                                                return TextButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    // _closeAudioSettingsOverlayBox();

                                                    String translationId =
                                                        NonSegmentedRecitersClass
                                                            .translations[index]
                                                                ["id"]
                                                            .toString();

                                                    // ----
                                                    updateReciterAndLoadAudio(
                                                        id: translationId,
                                                        index: index,
                                                        audioPlayerState:
                                                            audioPlayerState);
                                                  },
                                                  child: ListTile(
                                                    enableFeedback: true,
                                                    tileColor: settingsState
                                                                .selectedReciterId
                                                                .toString() ==
                                                            NonSegmentedRecitersClass
                                                                .translations[
                                                                    index]["id"]
                                                                .toString()
                                                        ? selectedColor
                                                        : bgColor,
                                                    leading: CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/translators/${NonSegmentedRecitersClass.translations[index]["translator_name"]!.replaceAll(" ", "_")}.png')),

                                                    title: Text(
                                                        NonSegmentedRecitersClass
                                                                    .translations[
                                                                index][
                                                            "translator_name"]!,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),

                                                    subtitle: Text(
                                                      NonSegmentedRecitersClass
                                                              .translations[
                                                          index]["language"]!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ), // Add any other properties you need for the ListTile
                                                  ),
                                                );
                                              }),
                                        )
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Icon customIcon(
      {required double smallIconSize,
      required Icon iconName,
      required AudioSettingsOptions audioSettingsOption}) {
    return Icon(
      iconName.icon,
      size: smallIconSize,
      color: selectedAudioSubSettings == audioSettingsOption
          ? Colors.black
          : Colors.white,
    );
  }

  // returns a container with a text that says if the item is highlighted or not
  Widget buildHighlightContainer(
      {required bool isHighlighted, required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.green.withOpacity(0.15)
            : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        isHighlighted ? 'Highlighted' : 'No highlight',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

//   ===========
  void updateReciterAndLoadAudio({
    required String id,
    required int index,
    required AudioPlayerState audioPlayerState,
  }) {
    context.read<AudioPlayerBloc>().add(LoadAudioEvent(
        quranDisplayType: audioPlayerState.quranDisplayType,
        reciterId: id,
        surahOrJuzId: audioPlayerState.currentSurahOrJuzId,
        playFromVerseIndex: audioPlayerState.currentAudioIndex));
  }
}
