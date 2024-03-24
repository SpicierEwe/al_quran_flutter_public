import 'package:al_quran_new/logic/surah_display_bloc/surah_display_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'config_event.dart';

part 'config_state.dart';

class ConfigBloc extends HydratedBloc<ConfigEvent, ConfigState> {
  ConfigBloc() : super(const ConfigState()) {
    // this is the event that will be triggered when the user has seen the welcome screen
    on<SeenInitialScreensEventPassed>((event, emit) {
      emit(state.copyWith(hasSeenWelcomeScreen: true));
    });
  }

  @override
  ConfigState? fromJson(Map<String, dynamic> json) {
    try {
      return ConfigState(hasSeenWelcomeScreen: json["hasSeenWelcomeScreen"]);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ConfigState state) {
    try {
      return {
        "hasSeenWelcomeScreen": state.hasSeenWelcomeScreen,
      };
    } catch (_) {
      return null;
    }
  }
}
