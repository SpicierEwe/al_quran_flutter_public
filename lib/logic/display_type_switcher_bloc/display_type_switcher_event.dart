part of 'display_type_switcher_bloc.dart';

@immutable
abstract class DisplayTypeSwitcherEvent {}

class UpdateMushafModeEvent extends DisplayTypeSwitcherEvent {
  final bool? isMushafMode;

  UpdateMushafModeEvent({this.isMushafMode});
}

/* this will be executed when the tabs change cause if don't reset the convertedReadingScrollPositionIndex
    * then every time the user switches the surah it would be stating from the last position*/
class ResetConvertedReadingScrollPositionIndexEvent
    extends DisplayTypeSwitcherEvent {}

class GetVerseByVerseItemScrollControllerEvent
    extends DisplayTypeSwitcherEvent {
  final ItemScrollController itemScrollController;

  GetVerseByVerseItemScrollControllerEvent(this.itemScrollController);
}

class GetMushafItemScrollControllerEvent extends DisplayTypeSwitcherEvent {
  final ItemScrollController itemScrollController;

  GetMushafItemScrollControllerEvent(this.itemScrollController);
}
