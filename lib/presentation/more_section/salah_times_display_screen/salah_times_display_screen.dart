import 'dart:async';

import 'package:al_quran_new/logic/permissions_bloc/permissions_bloc.dart';
import 'package:al_quran_new/presentation/more_section/salah_times_display_screen/widgets/qibla_compass.dart';
import 'package:al_quran_new/presentation/more_section/salah_times_display_screen/widgets/salah_times_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../logic/salah_bloc/salah_bloc.dart';

class SalahTimesDisplayScreen extends StatefulWidget {
  const SalahTimesDisplayScreen({super.key});

  @override
  State<SalahTimesDisplayScreen> createState() =>
      _SalahTimesDisplayScreenState();
}

class _SalahTimesDisplayScreenState extends State<SalahTimesDisplayScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  late StreamSubscription<PermissionsState> permissionSubscription;
  @override
  void initState() {
    super.initState();

    final permissionsBloc = context.read<PermissionsBloc>();

    // Check if location permission is granted
    if (!permissionsBloc.state.isLocationPermissionGranted) {
      // Request location permission
      permissionsBloc.add(GetLocationPermission());
    } else {
      // Location permission is already granted, fetch Salah times
      context.read<SalahBloc>().add(GetSalahTimesEvent());
    }

    // Listen for changes in location permission state
     permissionSubscription = permissionsBloc.stream.listen((state) {
      if (state.isLocationPermissionGranted) {
        // If location permission is granted, fetch Salah times
        context.read<SalahBloc>().add(GetSalahTimesEvent());
        // Cancel the subscription after the event
        permissionSubscription.cancel();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    const List<Map<String, dynamic>> bottomNav = [
      {
        "title": "Salah Times",
        "icon": Icons.watch_later_rounded,
      },
      {
        "title": "Qibla",
        "icon": Icons.directions,
      },
    ];
    return PopScope(
      onPopInvoked: (_) {
        context.read<SalahBloc>().add(CancelTimerEvent());
      },
      child: BlocBuilder<PermissionsBloc, PermissionsState>(
        builder: (context, permissionsState) {
          // if no location permission granted
          if (!permissionsState.isLocationPermissionGranted) {
            return Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_off_rounded,
                            size: 50,
                            color: Colors.red,
                          ),
                          const Text(
                            "Location Permission Required",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Please grant location permission to use this feature",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<PermissionsBloc>()
                                  .add(GetLocationPermission());
                            },
                            child: const Text("Grant Permission"),
                          ),
                        ],
                      ),
                    ),
                  )),
            );
          }

          // if location permission granted
          return Scaffold(
              appBar: AppBar(
                title: const Text('Salah Times'),
                actions: [
                  // REFRESH BUTTOn
                  TextButton(
                    onPressed: () {
                      context
                          .read<SalahBloc>()
                          .add(GetSalahTimesEvent(forceFetch: true));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: .5.h,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 3.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.refresh_rounded),
                          Text("Refresh"),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                    // _selectedIndex = index;
                  });
                },
                items: bottomNav
                    .map(
                      (e) => BottomNavigationBarItem(
                        tooltip: e['title'].toString(),
                        icon: Icon(e['icon'] as IconData?),
                        label: (e['title'].toString()),
                      ),
                    )
                    .toList(),
              ),
              body: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: const [
                  SalahTimesDisplayWidget(),
                  QiblaCompassDisplayWidget(),
                ],
              ));
        },
      ),
    );
  }
}
