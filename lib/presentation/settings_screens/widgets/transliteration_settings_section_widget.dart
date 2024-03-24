import 'package:al_quran_new/logic/settings_bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransliterationSettingsSectionWidget extends StatefulWidget {
  final SettingsState settingsState;

  const TransliterationSettingsSectionWidget(
      {super.key, required this.settingsState});

  @override
  State<TransliterationSettingsSectionWidget> createState() =>
      _TransliterationSettingsSectionWidgetState();
}

class _TransliterationSettingsSectionWidgetState
    extends State<TransliterationSettingsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Show transliteration',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Switch(
              value: widget.settingsState.showTransliteration,
              onChanged: (value) {
                context
                    .read<SettingsBloc>()
                    .add(SettingsEventToggleTransliteration());
              },
            ),
          ],
        ),
      ],
    );
  }
}
