part of 'tafsir_bloc.dart';

@immutable
sealed class TafsirEvent {}

class GetAllTafsirsMetaData extends TafsirEvent {
  final int surahId;
  final int verseId;

  GetAllTafsirsMetaData({required this.surahId, required this.verseId});
}

class GetTafsirEvent extends TafsirEvent {
  final int tafsirId;
  final int surahId;
  final int verseId;

  GetTafsirEvent(
      {required this.tafsirId, required this.surahId, required this.verseId});
}
