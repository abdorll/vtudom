// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vtudom/function/navigator.dart';
import 'package:vtudom/routes/app_routes.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/utils/constants.dart';
import 'package:vtudom/views/web_view_page.dart';
import 'package:vtudom/widget/custom_elevated_button.dart';
import 'package:vtudom/widget/texts.dart';

class IntroScreenItem extends StatefulWidget {
  PageController pageController = PageController();

  IntroScreenItem(
      {required this.currentIndex,
      required this.itemIndex,
      required this.illustrationPath,
      required this.title,
      required this.subtitle,
      required this.pageController});

  String title, subtitle, illustrationPath;
  int currentIndex, itemIndex = 0;

  @override
  State<IntroScreenItem> createState() => _IntroScreenItemState();
}

class _IntroScreenItemState extends State<IntroScreenItem> {
  List<Widget> indicatorsList() {
    List<Padding> items = [];
    for (int i = 0; i <= 2; i++) {
      setState(() {});
      items.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: CircleAvatar(
          backgroundColor: widget.currentIndex == i
              ? primaryColor
              : primaryColor.withOpacity(0.4),
          radius: 4.5,
        ),
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Column(
            children: [
              Expanded(flex: 3, child: Image.asset(widget.illustrationPath)),
              Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextOf(widget.title, 19, black, FontWeight.w500),
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextOf(
                                  widget.subtitle, 12, black, FontWeight.w400),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.currentIndex < 2
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () => widget.pageController
                                        .animateToPage(2,
                                            duration:
                                                Duration(milliseconds: 100),
                                            curve: Curves.linear),
                                    child: Text('Skip')),
                                Row(
                                  children: indicatorsList(),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    widget.pageController.animateToPage(
                                        widget.currentIndex + 1,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: primaryColor,
                                    radius: 25,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: white,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : CustomElevatedButton(
                              text: "Get started",
                              onTap: () {
                                setRecognizedUser();
                                Navigation.forever(context,
                                    screenRoute: WebPage.webPage);
                              },
                            ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

Future setRecognizedUser() async {
  var user = await Hive.openBox(Constants.userBox);
  user.put(Constants.recognizedUser, true);
}
