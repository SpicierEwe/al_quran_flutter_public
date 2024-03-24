part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent {}

class ThemeChangedEvent extends ThemeEvent {
  final ThemeType themeType;

  ThemeChangedEvent({required this.themeType});
}
