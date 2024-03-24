part of 'config_bloc.dart';

@immutable
class ConfigState {
  final bool hasSeenWelcomeScreen;

  const ConfigState({
    this.hasSeenWelcomeScreen = false,
  });

  ConfigState copyWith({
    bool? hasSeenWelcomeScreen,
  }) {
    return ConfigState(
      hasSeenWelcomeScreen: hasSeenWelcomeScreen ?? this.hasSeenWelcomeScreen,
    );
  }
}
