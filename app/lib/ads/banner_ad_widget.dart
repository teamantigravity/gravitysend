import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';

/// Drop-in banner widget.
/// - Shows nothing if the user is ad-free
/// - Shows nothing on desktop/web (google_mobile_ads is Android/iOS only)
/// - Shows nothing while the ad is loading (no layout shift)
///
/// Usage — add at the bottom of any Scaffold body column:
///
///   Scaffold(
///     body: Column(children: [
///       Expanded(child: YourMainContent()),
///       const BannerAdWidget(),   // ← add this line
///     ]),
///   )
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    // Only attempt to load on supported platforms
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    _ad = AdManager.createBanner(
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); // dispose() is void
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    // load() returns Future<void> — fire-and-forget is intentional here
    _ad?.load();
  }

  @override
  void dispose() {
    _ad?.dispose(); // dispose() is void
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
