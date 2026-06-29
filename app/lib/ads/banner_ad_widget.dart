import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';

/// Drop-in banner widget.
/// - Shows nothing if the user is ad-free
/// - Shows nothing on desktop/web (google_mobile_ads is Android/iOS only)
/// - Shows nothing while the ad is loading (no layout shift)
/// - Listens to AdManager.initializedNotifier to reload once AdMob is ready
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
  int _retryAttempts = 0;

  @override
  void initState() {
    super.initState();
    AdManager.adFreeNotifier.addListener(_onAdFreeChanged);
    AdManager.initializedNotifier.addListener(_onInitialized);

    if (AdManager.adFreeNotifier.value) return;

    // If already initialized, load immediately. Otherwise wait for the notifier.
    if (AdManager.initializedNotifier.value) {
      _loadAd();
    }
  }

  void _onInitialized() {
    if (!mounted) return;
    if (AdManager.initializedNotifier.value && !AdManager.adFreeNotifier.value) {
      _loadAd();
    }
  }

  void _onAdFreeChanged() {
    if (!mounted) return;
    if (AdManager.adFreeNotifier.value) {
      final ad = _ad;
      if (ad != null) unawaited(ad.dispose());
      setState(() {
        _ad = null;
        _loaded = false;
      });
    }
  }

  void _loadAd() {
    if (!mounted) return;

    // Only attempt to load on supported platforms
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final oldAd = _ad;
    if (oldAd != null) unawaited(oldAd.dispose());
    _ad = AdManager.createBanner(
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _retryAttempts = 0;
          if (mounted) {
            setState(() {
              _loaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          unawaited(ad.dispose());
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
            _retryAttempts++;
            if (_retryAttempts < 5) {
              Future.delayed(Duration(seconds: 10 * _retryAttempts), () {
                _loadAd();
              });
            }
          }
        },
      ),
    );
    final newAd = _ad;
    if (newAd != null) unawaited(newAd.load());
  }

  @override
  void dispose() {
    AdManager.adFreeNotifier.removeListener(_onAdFreeChanged);
    AdManager.initializedNotifier.removeListener(_onInitialized);
    final adToDispose = _ad;
    if (adToDispose != null) unawaited(adToDispose.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdManager.adFreeNotifier.value) return const SizedBox.shrink();
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
