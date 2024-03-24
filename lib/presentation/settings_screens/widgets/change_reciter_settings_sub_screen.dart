import 'dart:ui';

import 'package:al_quran_new/core/constants/variables.dart';
import 'package:al_quran_new/logic/audio_player_bloc/audio_player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:sizer/sizer.dart';

import '../../../logic/settings_bloc/settings_bloc.dart';

class ChangeReciterSettingsSubScreen extends StatefulWidget {
  const ChangeReciterSettingsSubScreen({super.key});

  @override
  State<ChangeReciterSettingsSubScreen> createState() =>
      _ChangeReciterSettingsSubScreenState();
}

class _ChangeReciterSettingsSubScreenState
    extends State<ChangeReciterSettingsSubScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    const List<String> tabBarItems = [
      'Reciter',
      "Non Seg Reciters",
      'Translations'
    ];

    final segmentedRecitersList = context
        .read<SettingsBloc>()
        .state
        .allRecitersList
        .where((element) => !element["id"].toString().contains("non_seg"))
        .toList();

    final nonSegmentedRecitersList = context
        .read<SettingsBloc>()
        .state
        .allRecitersList
        .where((element) =>
            element["id"].toString().contains("non_seg") &&
            !element["id"].toString().contains("translation"))
        .toList();

    final translationRecitersList = context
        .read<SettingsBloc>()
        .state
        .allRecitersList
        .where((element) =>
            element["id"].toString().contains("non_seg") &&
            element["id"].toString().contains("translation"))
        .toList();

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return DefaultTabController(
          length: tabBarItems.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Change Reciter'),
              bottom: TabBar(
                tabs: [
                  for (final item in tabBarItems) Tab(text: item),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Segmented Reciter
                CustomGridViewBuilder(
                  settingsState: settingsState,
                  isSegmented: true,
                  isReciter: true,
                  dataList: segmentedRecitersList,
                ),

                // Non Segmented Reciter
                CustomGridViewBuilder(
                  settingsState: settingsState,
                  isSegmented: false,
                  isReciter: true,
                  dataList: nonSegmentedRecitersList,
                ),
                // Segmented Reciter
                // Segmented Reciter
                CustomGridViewBuilder(
                  settingsState: settingsState,
                  isSegmented: false,
                  isReciter: false,
                  dataList: translationRecitersList,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomGridViewBuilder extends StatefulWidget {
  final List dataList;

  final bool isReciter;
  final bool isSegmented;
  final SettingsState settingsState;

  const CustomGridViewBuilder({
    super.key,
    required this.dataList,
    required this.isReciter,
    required this.isSegmented,
    required this.settingsState,
  });

  @override
  State<CustomGridViewBuilder> createState() => _CustomGridViewBuilderState();
}

class _CustomGridViewBuilderState extends State<CustomGridViewBuilder> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 3.0.w,
        vertical: 2.0.h,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.7.w,
        mainAxisSpacing: 3.7.h,
        // childAspectRatio: .87,
        childAspectRatio: .83,
      ),
      itemCount: widget.dataList.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Material(
              elevation: widget.settingsState.selectedReciterId.toString() ==
                      widget.dataList[index]["id"].toString()
                  ? 3
                  : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  width: widget.settingsState.selectedReciterId.toString() ==
                          widget.dataList[index]["id"].toString()
                      ? 2
                      : 0,
                  color: widget.settingsState.selectedReciterId.toString() ==
                          widget.dataList[index]["id"].toString()
                      ? Colors.deepOrange
                      : Colors.transparent,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    image: AssetImage(
                      widget.isReciter
                          ? "assets/images/reciters/${widget.dataList[index]["reciter_name"].replaceAll(" ", "_")}.png"
                          : "assets/images/translators/${widget.dataList[index]["translator_name"].replaceAll(" ", "_")}.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    // =====================================
                    // switch reciters ( reciter or translator)
                    context.read<AudioPlayerBloc>().add(
                        SettingsReciterSwitchEvent(
                            reciterId:
                                widget.dataList[index]["id"].toString()));

                    // context.pop();
                  },
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: .5.h,
                            horizontal: 3.w,
                          ),
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.55),
                          child: Text(
                            widget.isReciter
                                ? widget.dataList[index]["reciter_name"]
                                : widget.dataList[index]["translator_name"],
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Colors.black87,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // custom chip container
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 2.w, top: 1.h),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // if  segmented
                      if (widget.isSegmented)
                        customChip(
                          context: context,
                          color: Colors.green,
                          chipTitleColor: Colors.white,
                          chipTitle: "Word Highlight",
                        ),
                      // if not segmented
                      if (!widget.isSegmented)
                        customChip(
                          context: context,
                          color: Colors.blue,
                          chipTitleColor: Colors.white,
                          chipTitle: "No Word Highlight",
                        ),
                      if (widget.dataList[index]["style"] != null)
                        customChip(
                          context: context,
                          color: Colors.white,
                          chipTitleColor: Colors.black87,
                          chipTitle: widget.dataList[index]["style"],
                        ),
                      if (!widget.isReciter)
                        customChip(
                          context: context,
                          color: Colors.white,
                          chipTitleColor: Colors.black87,
                          chipTitle: widget.dataList[index]["language"],
                        ),
                    ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget customChip({
    required BuildContext context,
    required Color color,
    required String chipTitle,
    Color? chipTitleColor,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: .5.h,
            horizontal: 2.w,
          ),
          child: Text(
            chipTitle,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontSize: 7.sp,
                  color: chipTitleColor,
                ),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}
