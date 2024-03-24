part of 'surah_names_bloc.dart';

@immutable
abstract class SurahNamesEvent {}

class UpdateSurahNamesMetadataEvent extends SurahNamesEvent {
  final List<dynamic> data;

  UpdateSurahNamesMetadataEvent({required this.data});
}

class ForceRefetchEvent extends SurahNamesEvent {}
