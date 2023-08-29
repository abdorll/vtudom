// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:vtudom/utils/sizes.dart';
import 'package:vtudom/widget/texts.dart';

smallBtn(String text, Color textColor, Color btnColor, VoidCallback action) {
  return InkWell(
    onTap: () {
      action();
    },
    child: Container(
      decoration: BoxDecoration(
          color: btnColor, borderRadius: BorderRadius.circular(50)),
      padding: EdgeInsets.symmetric(horizontal: 27, vertical: 14),
      child: TextOf(text, size2, textColor, FontWeight.w500),
    ),
  );
}
