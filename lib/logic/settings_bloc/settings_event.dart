part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsEventChangeQuranFont extends SettingsEvent {
  final int index;
  final String fontName;

  SettingsEventChangeQuranFont({required this.index, required this.fontName});
}

class SettingsEventGetAllTranslationIds extends SettingsEvent {
  final String languageName;

  SettingsEventGetAllTranslationIds({required this.languageName});
}

class SettingsEventChangeTranslation extends SettingsEvent {
  final int translationId;

  SettingsEventChangeTranslation({required this.translationId});
}

class UpdateSelectedReciterIdEvent extends SettingsEvent {
  final String reciterId;

  UpdateSelectedReciterIdEvent({required this.reciterId});
}

class UpdateTranslationFontSizeEvent extends SettingsEvent {
  final bool shouldIncrease;

  UpdateTranslationFontSizeEvent({required this.shouldIncrease});
}

class UpdateQuranTextFontSizeEvent extends SettingsEvent {
  final bool shouldIncrease;

  UpdateQuranTextFontSizeEvent({required this.shouldIncrease});
}

class UpdateQuranTextWordSpacingEvent extends SettingsEvent {
  final bool shouldIncrease;

  UpdateQuranTextWordSpacingEvent({required this.shouldIncrease});
}

class SettingsEventToggleTransliteration extends SettingsEvent {
  SettingsEventToggleTransliteration();
}

class SettingsEventGetAllReciters extends SettingsEvent {
  SettingsEventGetAllReciters();
}
