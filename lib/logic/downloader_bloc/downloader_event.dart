part of 'downloader_bloc.dart';

@immutable
abstract class DownloaderEvent {}

class DownloadQuranEvent extends DownloaderEvent {
  final bool isOnlyLanguageChange;

  DownloadQuranEvent({this.isOnlyLanguageChange = false});
}

class RetryDownloadEvent extends DownloaderEvent {}

class DownloadAdditionalTranslationEvent extends DownloaderEvent {
  final String translationId;
  final BuildContext context;

  DownloadAdditionalTranslationEvent(
      {required this.translationId, required this.context});
}
