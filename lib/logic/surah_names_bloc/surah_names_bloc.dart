import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import '../repositories/internet_data_repository.dart';

part 'surah_names_event.dart';

part 'surah_names_state.dart';

class SurahNamesBloc extends HydratedBloc<SurahNamesEvent, SurahNamesState> {
  SurahNamesBloc() : super(const SurahNamesState()) {
    on<UpdateSurahNamesMetadataEvent>((event, emit) async {
      emit(state.copyWith(surahNamesMetaData: event.data));
    });
  }

  @override
  SurahNamesState? fromJson(Map<String, dynamic> json) {
    return SurahNamesState(
      surahNamesMetaData: json["surahNamesMetaData"],
      selectedSurah: json["selectedSurah"],
    );
  }

  @override
  Map<String, dynamic>? toJson(SurahNamesState state) {
    return {
      "surahNamesMetaData": state.surahNamesMetaData,
      "selectedSurah": state.selectedSurah,
    };
  }
}
