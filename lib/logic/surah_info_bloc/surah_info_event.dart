part of 'surah_info_bloc.dart';

@immutable
sealed class SurahInfoEvent {}

class GetSurahInfo extends SurahInfoEvent {
  final int surahId;
  final String languageCode;

  GetSurahInfo({required this.surahId, required this.languageCode});
}
