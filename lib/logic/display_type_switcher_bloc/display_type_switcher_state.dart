part of 'display_type_switcher_bloc.dart';

@immutable
class DisplayTypeSwitcherState {
  final bool isMushafMode;

  /* this is dynamically generated when the user switches from
  verse by verse mode to mushaf mode or vice verse

  when user switches from verse by verse mode to mushaf mode this will contain the page index which is converted from the
  verse index of the verse by verse page.

  And when the user switches from the mushaf mode to verse by verse mode this will contain the verse index which
   is converted from the page index
   */
  final int? convertedReadingScrollPositionIndex;

  final ItemScrollController? verseByVerseItemScrollController;
  final ItemScrollController? mushafItemScrollController;

  const DisplayTypeSwitcherState({
    this.convertedReadingScrollPositionIndex,
    this.verseByVerseItemScrollController,
    this.mushafItemScrollController,
    this.isMushafMode = false,
  });

  DisplayTypeSwitcherState copyWith({
    bool? isMushafMode,
    int? convertedReadingScrollPositionIndex,
    ItemScrollController? verseByVerseItemScrollController,
    ItemScrollController? mushafItemScrollController,
  }) {
    return DisplayTypeSwitcherState(
      convertedReadingScrollPositionIndex:
          convertedReadingScrollPositionIndex ??
              this.convertedReadingScrollPositionIndex,
      isMushafMode: isMushafMode ?? this.isMushafMode,
      verseByVerseItemScrollController: verseByVerseItemScrollController ??
          this.verseByVerseItemScrollController,
      mushafItemScrollController:
          mushafItemScrollController ?? this.mushafItemScrollController,
    );
  }
}
