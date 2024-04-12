import 'package:al_quran_new/core/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperSection extends StatefulWidget {
  const DeveloperSection({super.key});

  @override
  State<DeveloperSection> createState() => _DeveloperSectionState();
}

class _DeveloperSectionState extends State<DeveloperSection> {
  @override
  Widget build(BuildContext context) {
    // ===============================
    final List<Map<String, dynamic>> options = [
      {
        "title": "Dev Portfolio",
        "subtitle": "The Portfolio of the developer.",
        "icon": Icons.person,
        "onTap": () {
          // Open the developer's portfolio
          launchUrl(Uri.parse("https://hammadtayyab.vercel.app/"));
        },
      },
      {
        "title": "Email us",
        "subtitle": "Quickly reach us through an email.",
        "icon": Icons.email,
        "onTap": () async {
          String? encodeQueryParameters(Map<String, String> params) {
            return params.entries
                .map((MapEntry<String, String> e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
          }

// ···
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: 'dev.abeliever@gmail.com',
            query: encodeQueryParameters(<String, String>{
              'subject': 'Feedback or Inquiry or Greetings',
              'body': 'Dear Developer, \n\n',
            }),
          );

          launchUrl(emailLaunchUri);
        },
      } , {
        "title": "Privacy Policy",
        "subtitle": "Quickly reach us through an email.",
        "icon": Icons.email,
        "onTap": () async {
          context.push("/privacy_policy_screen");
        },
      }
    ];

    return Column(
      children: [
        Column(
          children: options
              .map((option) => ListTile(
                    title: Text(option["title"]),
                    subtitle: Text(option["subtitle"]),
                    leading: Icon(option["icon"]),
                    onTap: option["onTap"],
                  ))
              .toList(),
        ),
        SizedBox(height: 3.h),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Qur'an Data Source: "),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse("https://quran.com/"));
                  },
                  child: const Text(
                    "Quran.com",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("App version: "),
                Text(
                  AppVariables.appVersion,
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
