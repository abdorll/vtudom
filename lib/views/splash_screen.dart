// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vtudom/function/navigator.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/utils/constants.dart';
import 'package:vtudom/utils/images.dart';
import 'package:vtudom/views/intro_screens.dart';
import 'package:vtudom/views/web_view_page.dart';

class SplashScreen extends StatefulWidget {
  static const String splashScreen = "splash_screen";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void nextPage() async {
    var openBox = await Hive.openBox(Constants.userBox);
    print('USER RECOGNIZED STATUS IS --------- ${Constants.recognizedUser}');
    bool recognized = openBox.get(Constants.recognizedUser) ?? false;
    Future.delayed(Duration(seconds: 3), () {
      recognized == false
          ? Navigation.forever(context, screenRoute: IntroScreens.introScreens)
          : Navigation.forever(context, screenRoute: WebPage.webPage);
    });
  }

  @override
  void initState() {
    super.initState();
    nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Image.asset(
          ImageOf.splashScreenImage,
          height: 150,
        ),
      ),
    );
  }
}
