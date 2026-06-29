import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitysend_app/ads/ad_ids.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns true only on platforms where google_mobile_ads is supported.
/// google_mobile_ads supports Android and iOS only — desktop/web are excluded.
bool get _adsSupported =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Central ad controller for Gravity Send.
/// Call AdManager.init() in main() before runApp().
/// Call AdManager.showInterstitialAfterTransfer() after a transfer completes.
/// Call AdManager.showAppOpenAd() on app foreground resume.
class AdManager {
  AdManager._();

  static bool _initialized = false;
  static bool _adFree = false;
  static InterstitialAd? _interstitialAd;
  static int _interstitialRetryAttempts = 0;
  static AppOpenAd? _appOpenAd;
  static bool _appOpenAdLoading = false;
  static int _appOpenRetryAttempts = 0;
  static DateTime? _appOpenLoadTime;

  /// Reactive ad-free state. Widgets (e.g. banners) can listen to this to
  /// hide ads immediately after an in-app purchase without needing a rebuild.
  static final ValueNotifier<bool> adFreeNotifier = ValueNotifier<bool>(false);

  /// Reactive initialized state. BannerAdWidget listens to this so it can
  /// reload itself once AdMob finishes initializing asynchronously.
  static final ValueNotifier<bool> initializedNotifier = ValueNotifier<bool>(false);

  // ── Init ─────────────────────────────────────────────────────
  static Future<void> init() async {
    // google_mobile_ads is Android/iOS only — skip entirely on desktop/web
    if (!_adsSupported) return;

    try {
      // Await initialization so ad requests don't race with incomplete init
      await MobileAds.instance.initialize();

      final prefs = await SharedPreferences.getInstance();
      _adFree = prefs.getBool('gravitysend_ad_free') ?? false;
      adFreeNotifier.value = _adFree;
      _initialized = true;
      initializedNotifier.value = true;

      if (!_adFree) {
        _preloadInterstitial();
        _preloadAppOpenAd();
      }
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
    adFreeNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gravitysend_ad_free', value);
    if (value) {
      final ad = _interstitialAd;
      if (ad != null) unawaited(ad.dispose());
      _interstitialAd = null;
      final appOpenAd = _appOpenAd;
      if (appOpenAd != null) unawaited(appOpenAd.dispose());
      _appOpenAd = null;
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
              unawaited(ad.dispose());
              _interstitialAd = null;
              _preloadInterstitial(); // pre-load next immediately
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              unawaited(ad.dispose());
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _interstitialRetryAttempts++;
          if (_interstitialRetryAttempts < 6) {
            final seconds = 1 << _interstitialRetryAttempts;
            Future.delayed(Duration(seconds: seconds), _preloadInterstitial);
          }
        },
      ),
    ));
  }

  static int _adhocEventCounter = 0;

  /// Call this AFTER a file transfer completes successfully.
  static void showInterstitialAfterTransfer() {
    if (!_adsSupported || !_initialized || _adFree || _interstitialAd == null) return;
    unawaited(_interstitialAd!.show());
  }

  /// Call this on frequent actions (like tab switches or settings opening).
  /// Shows an ad every time to maximize revenue (aggressive Pro monetization).
  static void showInterstitialAdhoc() {
    if (!_adsSupported || !_initialized || _adFree || _interstitialAd == null) return;
    unawaited(_interstitialAd!.show());
  }

  // ── App Open Ad ───────────────────────────────────────────────
  /// Preloads an App Open Ad. Called automatically after init.
  static void _preloadAppOpenAd() {
    if (!_adsSupported || !_initialized || _adFree || _appOpenAdLoading) return;
    if (_appOpenAd != null) return;
    _appOpenAdLoading = true;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAdLoading = false;
          _appOpenRetryAttempts = 0;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _appOpenAdLoading = false;
          _appOpenRetryAttempts++;
          if (_appOpenRetryAttempts < 5) {
            final seconds = 1 << _appOpenRetryAttempts;
            Future.delayed(Duration(seconds: seconds), _preloadAppOpenAd);
          }
        },
      ),
    );
  }

  /// Returns true if the loaded App Open Ad is still fresh (< 4 hours old).
  static bool _isAppOpenAdAvailable() {
    if (_appOpenAd == null) return false;
    final loadTime = _appOpenLoadTime;
    if (loadTime == null) return false;
    return DateTime.now().difference(loadTime) < const Duration(hours: 4);
  }

  /// Call this when the app is foregrounded (AppLifecycleState.resumed).
  /// Shows the App Open Ad if available. Safe to call on all platforms —
  /// the _adsSupported check ensures no-op on desktop/web.
  static void showAppOpenAd() {
    if (!_adsSupported || !_initialized || _adFree) return;
    if (!_isAppOpenAdAvailable()) {
      _preloadAppOpenAd(); // reload if stale or missing
      return;
    }
    final ad = _appOpenAd!;
    _appOpenAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        _preloadAppOpenAd(); // pre-load the next one
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        _preloadAppOpenAd();
      },
    );
    unawaited(ad.show());
  }
}
