import 'package:flutter/material.dart';
import 'package:vtudom/utils/images.dart';
import 'package:vtudom/widget/intro_screens_basics.dart';

class IntroScreens extends StatefulWidget {
  static const String introScreens = "intro_screens";
  const IntroScreens();

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  late PageController _pageController;

  int currentIndex = 0;
  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int value) {
    setState(() {
      currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<IntroScreenItem> introScreenItems = [
      IntroScreenItem(
        itemIndex: 0,
        currentIndex: currentIndex,
        pageController: _pageController,
        illustrationPath: ImageOf.slide1,
        title: 'Welcome to VTUDOM',
        subtitle:
            'Streamline Your Life with Seamless Digital Services Anytime, Anywhere',
      ),
      IntroScreenItem(
        itemIndex: 1,
        currentIndex: currentIndex,
        pageController: _pageController,
        illustrationPath: ImageOf.slide2,
        title: ' Simplify Payments',
        subtitle:
            'Effortlessly Recharge Airtime, Purchase Data Bundles, and Settle Utility Bills on Demand.',
      ),
      IntroScreenItem(
        itemIndex: 2,
        currentIndex: currentIndex,
        pageController: _pageController,
        illustrationPath: ImageOf.slide3,
        title: 'Empowering Convenience',
        subtitle:
            ' Embrace the Future of Easy Digital Services – Your One-Stop Vending Solution in Nigeria.',
      ),
    ];
    return Scaffold(
      body: PageView(
        physics: BouncingScrollPhysics(),
        controller: _pageController,
        children: introScreenItems,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
