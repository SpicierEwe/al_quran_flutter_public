part of 'bookmark_bloc.dart';

const Map<String, dynamic> lastReadStructure = {
  "verse_index": null,
  "surah_index": null,
  "page_index": null,
  "juz_index": null,
};

@immutable
class BookmarkState {
  final Map<String, dynamic> lastRead;
  final List<dynamic> favourites;
  final BookmarkType bookmarkType;

  // will contain value only when user clicks on a favourite verse and whats to redirect
  //  after redirecting to the verse, this value will be set to -1 ( represents invalid ) to avoid any other unwanted
  //  behaviour or redirections
  final int redirectFavouriteVerseIndex;

  const BookmarkState({
    this.bookmarkType = BookmarkType.surah,
    this.redirectFavouriteVerseIndex = -1,
    this.lastRead = lastReadStructure,
    this.favourites = const [],
  });

  BookmarkState copyWith({
    BookmarkType? bookmarkType,
    Map<String, dynamic>? lastRead,
    List<dynamic>? favourites,
    int? redirectFavouriteVerseIndex,
  }) {
    return BookmarkState(
      bookmarkType: bookmarkType ?? this.bookmarkType,
      lastRead: lastRead ?? this.lastRead,
      favourites: favourites ?? this.favourites,
      redirectFavouriteVerseIndex:
          redirectFavouriteVerseIndex ?? this.redirectFavouriteVerseIndex,
    );
  }
}
