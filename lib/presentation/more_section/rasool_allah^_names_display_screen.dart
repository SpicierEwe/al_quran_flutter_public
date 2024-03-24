import 'package:al_quran_new/core/constants/allah_and_rasool_names.dart';
import 'package:al_quran_new/core/constants/custom_themes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RasoolAllahNamesDisplayScreen extends StatelessWidget {
  const RasoolAllahNamesDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rasool Allah Names'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 3.h,
        ),
        itemCount: AllahAndRasoolNames.rasoolAllahNames.length,
        itemBuilder: (BuildContext context, int index) {
          String nameEn =
              AllahAndRasoolNames.rasoolAllahNames[index]["english_name"];
          String meaning =
              AllahAndRasoolNames.rasoolAllahNames[index]["english_meaning"];
          // the font translates the symbol to the arabic name
          String nameAr =
              AllahAndRasoolNames.rasoolAllahNames[index]["arabic_name"];

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
                      shape: BoxShape.circle,
                      color: Color(0xffaaa375),
                    ),
                    child: Image.asset(
                      'assets/images/allah_and_rasool_name_images/rasool_allah_name.png',
                      height: 20.h,
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
                            context: context,
                          ),
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
                      child: Text(nameAr,
                          style: TextStyle(
                            fontSize: 23.sp,
                            fontFamily: 'rasool_allah_names_font',
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
