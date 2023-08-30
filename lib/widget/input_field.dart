// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/utils/sizes.dart';
import 'package:vtudom/widget/iconss.dart';
import 'package:vtudom/widget/texts.dart';
import 'package:vtudom/widget/spacing.dart';

class Inputfield extends ConsumerWidget {
  Inputfield({
    required this.field,
    required this.icon,
    required this.onChanged,
    this.inputType = TextInputType.name,
    Key? key,
  }) : super(key: key);
  String field;
  IconData icon;
  Function(String?) onChanged;
  TextInputType inputType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            TextOf(field, size1, grey, FontWeight.w600),
          ],
        ),
        const YMargin(5),
        TextFormField(
          onChanged: onChanged,
          cursorColor: primaryColor,
          keyboardType: inputType,
          //keyboardAppearance: ,
          style: GoogleFonts.mulish(),
          decoration: InputDecoration(
              prefixIcon: IconOf(icon, size4, ash),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: primaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, color: red),
                  borderRadius: const BorderRadius.all(Radius.circular(10)))),
        ),
      ],
    );
  }
}

class PasswordField extends ConsumerWidget {
  PasswordField({
    required this.field,
    required this.icon,
    required this.onChanged,
    Key? key,
  }) : super(key: key);
  String field;
  IconData icon;
  final inVisible = StateProvider<bool>((ref) => true);
  Function(String?) onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            TextOf(field, size1, grey, FontWeight.w600),
          ],
        ),
        const YMargin(5),
        TextFormField(
          onChanged: onChanged,
          cursorColor: primaryColor,
          obscureText: ref.watch(inVisible),
          style: GoogleFonts.mulish(),
          decoration: InputDecoration(
              prefixIcon: IconOf(icon, size4, ash),
              suffixIcon: InkWell(
                  onTap: () {
                    ref.read(inVisible.notifier).state = !ref.watch(inVisible);
                  },
                  child: Column(
                    children: [
                      const YMargin(13),
                      TextOf(
                          ref.watch(inVisible) == false ? 'Hide' : 'Show',
                          size2,
                          ref.watch(inVisible) == false
                              ? primaryColor
                              : red.withOpacity(0.5),
                          FontWeight.bold),
                    ],
                  )),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, color: red),
                  borderRadius: const BorderRadius.all(Radius.circular(10)))),
        ),
      ],
    );
  }
}
