part of 'audio_bottom_bar_bloc.dart';

@immutable
class AudioBottomBarState {
  final List allRecitersList;

  const AudioBottomBarState({this.allRecitersList = const []});

  AudioBottomBarState copyWith({
    List? allRecitersList,
  }) {
    return AudioBottomBarState(
      allRecitersList: allRecitersList ?? this.allRecitersList,
    );
  }
}
