// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class PageBackground extends StatelessWidget {
  PageBackground(
      {required this.background,required this.body,Key? key})
      : super(key: key);
  String background;
  Widget body; 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (mask) => LinearGradient(
                  colors: [Colors.black26,Colors.black87,],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter)
              .createShader(mask),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(background), fit: BoxFit.cover)),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: body,
        )
      ],
    );
  }
}
