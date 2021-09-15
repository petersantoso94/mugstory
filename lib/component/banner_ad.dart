import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mugstory/ad_helper.dart';

class MBannerAd extends StatefulWidget {
  MBannerAd({Key? key}) : super(key: key);

  @override
  _MBannerAdState createState() => _MBannerAdState();
}

class _MBannerAdState extends State<MBannerAd> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
          _createBannerAd();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void initState() {
    _createBannerAd();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBannerAdReady)
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: _bannerAd.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd),
        ),
      );
    return Container();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
}
