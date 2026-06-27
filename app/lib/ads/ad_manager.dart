import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_ids.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns true only on platforms where google_mobile_ads is supported.
/// google_mobile_ads supports Android and iOS only.
bool get _adsSupported =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Central ad controller for GravitySend.
/// Call AdManager.init() in main() before runApp().
/// Call AdManager.showInterstitialAfterTransfer() after a transfer completes.
class AdManager {
  AdManager._();

  static bool _initialized = false;
  static bool _adFree = false;
  static InterstitialAd? _interstitialAd;
  static int _interstitialRetryAttempts = 0;

  /// Reactive ad-free state. Widgets (e.g. banners) can listen to this to
  /// hide ads immediately after an in-app purchase without needing a rebuild.
  static final ValueNotifier<bool> adFreeNotifier = ValueNotifier<bool>(false);

  // ── Init ─────────────────────────────────────────────────────
  static Future<void> init() async {
    // google_mobile_ads is Android/iOS only — skip entirely on desktop/web
    if (!_adsSupported) return;

    try {
      // Await initialization so ad requests don't race with incomplete init
      await MobileAds.instance.initialize();
      
      if (kDebugMode) {
        // Enforce test mode configuration for emulators and physical devices in debug
        final requestConfiguration = RequestConfiguration(
          testDeviceIds: [
            // Add standard test device IDs here if needed
            // 'YOUR_DEVICE_ID', 
          ],
        );
        unawaited(MobileAds.instance.updateRequestConfiguration(requestConfiguration));
      }

      final prefs = await SharedPreferences.getInstance();
      _adFree = prefs.getBool('gravitysend_ad_free') ?? false;
      adFreeNotifier.value = _adFree;
      _initialized = true;
      if (!_adFree) _preloadInterstitial();
    } catch (_) {
      // If AdMob fails to init (no network, policy issue, simulator, etc.)
      // the app continues normally — ads just won't show.
      _initialized = false;
    }
  }

  // ── Ad-free status ────────────────────────────────────────────
  static bool get isAdFree => _adFree;

  static Future<void> setAdFree(bool value) async {
    _adFree = value;
    adFreeNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gravitysend_ad_free', value);
    if (value) {
      final ad = _interstitialAd;
      if (ad != null) unawaited(ad.dispose());
      _interstitialAd = null;
    }
  }

  // ── Banner ────────────────────────────────────────────────────
  /// Returns a new BannerAd instance (not yet loaded) or null if:
  ///   - Platform is not Android/iOS
  ///   - User is ad-free
  ///   - AdMob failed to initialize
  static BannerAd? createBanner({BannerAdListener? listener}) {
    if (!_adsSupported || !_initialized || _adFree) return null;
    return BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }

  // ── Interstitial ──────────────────────────────────────────────
  static void _preloadInterstitial() {
    if (!_adsSupported || !_initialized || _adFree || _interstitialAd != null) return;
    unawaited(InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialRetryAttempts = 0;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              unawaited(ad.dispose()); // void — no unawaited needed
              _interstitialAd = null;
              _preloadInterstitial(); // pre-load next one immediately
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              unawaited(ad.dispose()); // void
              _interstitialAd = null;
              _preloadInterstitial(); // pre-load next one immediately if show failed
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _interstitialRetryAttempts++;
          if (_interstitialRetryAttempts < 6) {
            final seconds = 1 << _interstitialRetryAttempts;
            Future.delayed(Duration(seconds: seconds), () {
              _preloadInterstitial();
            });
          }
        },
      ),
    ));
  }

  static int _adhocEventCounter = 0;

  /// Call this AFTER a file transfer completes successfully.
  /// Shows a full-screen ad once, then silently reloads the next.
  static void showInterstitialAfterTransfer() {
    if (!_adsSupported || !_initialized || _adFree || _interstitialAd == null) return;
    unawaited(_interstitialAd!.show()); // returns Future<void> but fire-and-forget is fine here
  }

  /// Call this on frequent actions (like tab switches or settings opening).
  /// It will only show the ad every Nth time to avoid spamming the user.
  static void showInterstitialAdhoc() {
    if (!_adsSupported || !_initialized || _adFree || _interstitialAd == null) return;
    
    _adhocEventCounter++;
    // Show interstitial every 4 adhoc events (e.g. tab switches)
    if (_adhocEventCounter >= 4) {
      _adhocEventCounter = 0;
      unawaited(_interstitialAd!.show());
    }
  }
}
