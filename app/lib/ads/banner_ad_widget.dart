import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';

/// Drop-in banner widget. Shows nothing if user is ad-free or on desktop.
/// Usage: just add `const BannerAdWidget()` at the bottom of any Scaffold.
///
///   Scaffold(
///     body: Column(children: [
///       Expanded(child: YourMainContent()),
///       const BannerAdWidget(),   // ← add this line
///     ]),
///   )
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = AdManager.createBanner(
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          unawaited(ad.dispose());
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    unawaited(_ad?.load());
  }

  @override
  void dispose() {
    unawaited(_ad?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
