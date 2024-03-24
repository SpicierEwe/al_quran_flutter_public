import 'dart:async';

import 'package:al_quran_new/core/constants/non_segmented_reciters.dart';
import 'package:al_quran_new/logic/repositories/internet_data_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../audio_player_bloc/audio_player_bloc.dart';

part 'audio_bottom_bar_event.dart';

part 'audio_bottom_bar_state.dart';

class AudioBottomBarBloc
    extends Bloc<AudioBottomBarEvent, AudioBottomBarState> {
  AudioPlayerBloc audioPlayerBloc;

  AudioBottomBarBloc({required this.audioPlayerBloc})
      : super(const AudioBottomBarState()) {
    on<GetAllRecitersEvent>(
      (event, emit) async {
        await InternetDataRepository().getAllReciters(
          onCompleted: (reciters) {
            List tempRecitersList = reciters;
            // make alafasy reciter the first reciter
            // extracting alafasy reciter from the list
            List filteredList = reciters
                .where((element) => element["id"].toString() == "7")
                .toList();
            // removing alafasy reciter from the main list
            tempRecitersList
                .removeWhere((element) => element["id"].toString() == "7");
            emit(state.copyWith(allRecitersList: [
              ...filteredList,
              ...reciters,
              ...NonSegmentedRecitersClass.reciters
            ]));
          },
          onError: (error) {
            print('Error: $error');
          },
        );
      },
    );
  }
}
