import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_ids.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central ad controller for GravitySend.
/// Call AdManager.init() in main() before runApp().
/// Call AdManager.showInterstitialIfReady() after a transfer completes.
class AdManager {
  AdManager._();

  static bool _initialized = false;
  static bool _adFree       = false;
  static InterstitialAd? _interstitialAd;

  // ── Init ─────────────────────────────────────────────────────
  static Future<void> init() async {
    try {
      unawaited(MobileAds.instance.initialize());
      final prefs = await SharedPreferences.getInstance();
      _adFree = prefs.getBool('gravitysend_ad_free') ?? false;
      _initialized = true;
      if (!_adFree) _preloadInterstitial();
    } catch (_) {
      // If AdMob fails to init (no network, policy issue, etc.)
      // the app continues normally — ads just won't show.
      _initialized = false;
    }
  }

  // ── Ad-free status ────────────────────────────────────────────
  static bool get isAdFree => _adFree;

  static Future<void> setAdFree(bool value) async {
    _adFree = value;
    final prefs = await SharedPreferences.getInstance();
    unawaited(prefs.setBool('gravitysend_ad_free', value));
    if (value) {
      unawaited(_interstitialAd?.dispose());
      _interstitialAd = null;
    }
  }

  // ── Banner ────────────────────────────────────────────────────
  /// Returns a loaded BannerAd or null if ad-free / not initialized.
  static BannerAd? createBanner({BannerAdListener? listener}) {
    if (!_initialized || _adFree) return null;
    return BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }

  // ── Interstitial ──────────────────────────────────────────────
  static void _preloadInterstitial() {
    if (!_initialized || _adFree) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              unawaited(ad.dispose());
              _interstitialAd = null;
              _preloadInterstitial(); // pre-load next one
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              unawaited(ad.dispose());
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Call this AFTER a file transfer completes successfully.
  /// It shows a full-screen ad once, then reloads the next one silently.
  static void showInterstitialAfterTransfer() {
    if (!_initialized || _adFree || _interstitialAd == null) return;
    unawaited(_interstitialAd!.show());
  }
}
