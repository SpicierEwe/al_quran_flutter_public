part of 'theme_bloc.dart';

@immutable
class ThemeState {
  final ThemeType selectedThemeType;
  final ThemeData? themeData;

  const ThemeState({this.selectedThemeType = ThemeType.light, this.themeData});

  ThemeState copyWith({
    ThemeType? selectedThemeType,
    ThemeData? themeData,
  }) {
    return ThemeState(
      selectedThemeType: selectedThemeType ?? this.selectedThemeType,
      themeData: themeData ?? this.themeData,
    );
  }
}
