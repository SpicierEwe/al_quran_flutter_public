import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonName;

  final double? fontSize;

  const CustomButton({
    Key? key,
    required this.buttonName,
    required this.onPressed,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: TextStyle(fontSize: fontSize ?? 15.sp),
      ),
    );
  }
}
