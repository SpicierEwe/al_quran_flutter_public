import 'package:al_quran_new/core/constants/allah_and_rasool_names.dart';
import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:al_quran_new/core/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AllahNamesDisplayScreen extends StatelessWidget {
  const AllahNamesDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allah Names'),
      ),
      body: ListView.builder(
        itemCount: AllahAndRasoolNames.allahNames.length,
        itemBuilder: (BuildContext context, int index) {
          String nameEn =
              AllahAndRasoolNames.allahNames[index]["transliteration"];
          String meaning = AllahAndRasoolNames.allahNames[index]["meaning"];
          // the font translates the symbol to the arabic name
          String fontSymbol = AllahAndRasoolNames.allahNames[index]["symbol"];
          return Builder(
            builder: (context) => Column(
              children: [
                if (index == 0)
                  Container(
                    // padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
                    margin: EdgeInsets.symmetric(vertical: 5.h),

                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        shape: BoxShape.circle,
                        color: AppVariables.companyColorGold),
                    child: Image.asset(
                      'assets/images/allah_and_rasool_name_images/allah_name_white.png',
                      height: 25.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        // Numbering
                        leading: CircleAvatar(
                          backgroundColor: CustomThemes
                              .allahAndRasoolNamesCountColorAndTextTheme(
                                  context: context),
                          radius: 15,
                          child: Text((index + 1).toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith()),
                        ),
                        // English name
                        title: Text(nameEn),
                        // Meaning
                        subtitle: Text(meaning),
                      ),
                    ),

                    // Arabic name
                    Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: Text(fontSymbol,
                          style: TextStyle(
                            fontSize: 45.sp,
                            fontFamily: CustomThemes
                                .allahAndRasoolNamesCountColorAndTextTheme(
                                    context: context, allahNamesTextFont: true),
                          )),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
