import 'package:flutter/material.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/widget/texts.dart';

@immutable
class CustomElevatedButton extends StatelessWidget {
  CustomElevatedButton(
      {super.key,
      required this.text,
      required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  25,
                ),
              ),
            ).copyWith(
                fixedSize: MaterialStateProperty.all<Size>(
                    Size(double.maxFinite, 52))),
            onPressed: () {
              onTap();
            },
            child: TextOf(text, 12, white, FontWeight.w400)));
  }
}
