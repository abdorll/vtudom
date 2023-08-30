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
        illustrationPath: ImageOf.logo,
        title: 'Easy Ride Booking',
        subtitle:
            'Experience the ease of booking a ride with just a few taps, ensuring a seamless and hassle-free journey.',
      ),
      IntroScreenItem(
        itemIndex: 1,
        currentIndex: currentIndex,
        pageController: _pageController,
        illustrationPath: ImageOf.logo,
        title: 'Seamless Payment',
        subtitle:
            'Add funds to your wallet conveniently and use the funds to pay for your ride effortlessly.',
      ),
      IntroScreenItem(
        itemIndex: 2,
        currentIndex: currentIndex,
        pageController: _pageController,
        illustrationPath: ImageOf.logo,
        title: 'Refer and Earn',
        subtitle:
            'You get a referral bonus when you invite friends to download the app, sign up with your promo code and book a ride.',
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
