import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vtudom/utils/constants.dart';
class BannerAdMobContainer extends StatefulWidget {
  const BannerAdMobContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<BannerAdMobContainer> createState() => BannerAdMobContainerState();
}

class BannerAdMobContainerState extends State<BannerAdMobContainer> {
  BannerAd? bannerAd;

  bool isLoaded = false;
  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (bannerAd != null) {
      bannerAd!.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (!isLoaded || bannerAd == null) {
      loadAd();
    }
    return SizedBox(
      width: double.infinity, 
      height: bannerAd!.size.height.toDouble(),
      child: AdWidget(
        ad: bannerAd!,
      ),
    );
  }

  //-------------------------------------------
  void loadAd() async {
    if (kDebugMode) {
      print("loadAd: load ad one 1");
    }
    if (isLoaded || bannerAd != null) {
      return;
    }
    if (kDebugMode) {
      print("loadAd: load ad 2 bannerAdSize");
    }

    final AnchoredAdaptiveBannerAdSize? bannerAdSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    if (kDebugMode) {
      print("loadAd: load ad 3 bannerAdSize");
    }
    bannerAd = BannerAd(
      adUnitId: Constants.bannerAdUnit,
      request: const AdRequest(),
      size: bannerAdSize!,
      listener: BannerAdListener(
        onAdLoaded: (ad) { 
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          //this isLoaded booleans are important to display ads dont ever remove it
          setState(() {
            isLoaded = false;
          });
          ad.dispose();
        },
      ),
    )..load();
    if (kDebugMode) {
      print("loadAd: load ad one bannerAdSize loaded");
    }
  }
}
