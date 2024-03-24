import 'package:al_quran_new/logic/language_bloc/language_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants/strings.dart';
import '../../core/widgets/custom_buttons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    fit: BoxFit.cover,
                    image: const AssetImage(
                        'assets/images/welcome_screen_art.png'),
                    width: 100.w,
                    height: 40.h,
                  ),
                  Column(
                    children: [
                      Container(
                        height: 5.0.h,
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 7.h,
                          ),
                          Text(
                            AppStrings.welcomeScreenTitle,
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            AppStrings.welcomeScreenSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      CustomButton(
                          buttonName: 'Continue',
                          onPressed: () {
                            context.go('/choose_language');
                          }),
                    ],
                  ),
                ],
              ),
              // here is the app logo
              Positioned(
                top: 27.h,
                left: 37.w,
                child: Image(
                  fit: BoxFit.contain,
                  image: const AssetImage('assets/images/app_logo.png'),
                  width: 25.w,
                  height: 25.h,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
