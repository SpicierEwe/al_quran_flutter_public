import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'PRIVACY POLICY',
          style: TextStyle(fontSize: 14.1.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.0.h),
        child: ListView(
          children: [
            SizedBox(height: 2.0.h),
            permissionsInfo(
              context: context,
              title: 'REQUIRES INTERNET',
              description:
              'The App is semi-online which means it requires INTERNET to download all Quran files for the first time. After the data is downloaded successfully it can we viewed offline, but for some features a working internet is mandatory for example in order to see the tafsirs and play the recitation audio or for the Tajweed Quran Font.',
            ),
            permissionsInfo(
              context: context,
              title: 'REQUIRES Location Permissions',
              description:
              'Requires location permissions to fetch salah times and Qibla direction according to your location in order to show you the most accurate data.',
            ),
            permissionsInfo(
              context: context,
              title: 'Regarding your Private Information',
              description:
              'We do not Collect Any of Your Data either knowingly or unknowingly, and why would we? I haven\'t created this app to ruin myself On the Day of Judgement but rather to be close to my Lord The Most High (Allahuakabar), May Allah (The Almighty) Forgive us all and admit us all to Jannatul Firdausi al aala. Ameen',
            ),
            const Center(child: Text('*** * ***')),
            TextButton(
              child: Text(
                'Privacy - Policy',
                style: TextStyle(fontSize: 10.5.sp),
              ),
              onPressed: () async {
                final Uri url =
                    Uri.parse("https://spicierewe.vercel.app/al-Qur%27an/privacy-policy/");

                  await launchUrl(url);

              },
            ),
          ],
        ),
      ),
    );
  }

  Widget permissionsInfo({
    required String title,
    required String description,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$title',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 1.0.h),
          Text(
            '$description',
            textAlign: TextAlign.left,
          ),
          Divider(),
        ],
      ),
    );
  }
}
