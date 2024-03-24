part of 'bookmark_bloc.dart';

@immutable
abstract class BookmarkEvent {}

class AddBookmarkEvent extends BookmarkEvent {
  final int surahIndex;
  final int verseIndex;
  final BookmarkType bookmarkType;

  AddBookmarkEvent({
    required this.bookmarkType,
    required this.surahIndex,
    required this.verseIndex,
  });
}

class RemoveBookmarkEvent extends BookmarkEvent {
  RemoveBookmarkEvent();
}

class AddToFavouritesEvent extends BookmarkEvent {
  final int surahIndex;
  final int verseIndex;

  AddToFavouritesEvent({required this.surahIndex, required this.verseIndex});
}

class RemoveFromFavouritesEvent extends BookmarkEvent {
  final int surahIndex;
  final int verseIndex;

  RemoveFromFavouritesEvent(
      {required this.surahIndex, required this.verseIndex});
}

class RedirectToBookmarkEvent extends BookmarkEvent {
  final BuildContext context;

  RedirectToBookmarkEvent({required this.context});
}

class RedirectToFavouriteEvent extends BookmarkEvent {
  final int surahIndex;
  final int verseIndex;

  RedirectToFavouriteEvent(
      {required this.surahIndex, required this.verseIndex});
}

class ScrollToFavouriteVerseEvent extends BookmarkEvent {
  final ItemScrollController itemScrollController;

  ScrollToFavouriteVerseEvent({
    required this.itemScrollController,
  });
}
