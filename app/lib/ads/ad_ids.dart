// ── Gravity Send Ad IDs ─────────────────────────────────────────
// Real IDs are always active (hardcoded _useTestIds = false).
// All IDs sourced from admob.google.com for ca-app-pub-4989086156410627.
//
// Android:
//   App ID:        ca-app-pub-4989086156410627~9173182974
//   Banner:        ca-app-pub-4989086156410627/9751767477  (GS_Android_Banner)
//   Interstitial:  ca-app-pub-4989086156410627/9509598049  (GS_Android_Interstitial)
//   App Open:      ca-app-pub-4989086156410627/7043451887  (GS_Android_AppOpen)
//
// iOS:
//   App ID:        ca-app-pub-4989086156410627~2590891937
//   Banner:        ca-app-pub-4989086156410627/3939366695  (GravitySend_iOS_Banner)
//   Interstitial:  ca-app-pub-4989086156410627/9000121688  (GravitySend_iOS_Interstitial)
//   App Open:      ca-app-pub-4989086156410627/1791125207  (GS_IOS_AppOpen)

import 'package:flutter/foundation.dart';

class AdIds {
  // ── Toggle ──────────────────────────────────────────────────────
  // Hardcoded to false: ALWAYS serve real ads on all builds.
  static const bool _useTestIds = false;

  // ── Google Official Test IDs ─────────────────────────────────
  static const String _testBannerAndroid       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenAndroid      = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppIdAndroid        = 'ca-app-pub-3940256099942544~3347511713';

  static const String _testBannerIOS           = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIOS     = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testAppOpenIOS          = 'ca-app-pub-3940256099942544/5575463023';
  static const String _testAppIdIOS            = 'ca-app-pub-3940256099942544~1458002511';

  // ── Production IDs ───────────────────────────────────────────
  static const String _realAppIdAndroid        = 'ca-app-pub-4989086156410627~9173182974';
  static const String _realBannerAndroid       = 'ca-app-pub-4989086156410627/9751767477';
  static const String _realInterstitialAndroid = 'ca-app-pub-4989086156410627/9509598049';
  static const String _realAppOpenAndroid      = 'ca-app-pub-4989086156410627/7043451887';

  static const String _realAppIdIOS            = 'ca-app-pub-4989086156410627~2590891937';
  static const String _realBannerIOS           = 'ca-app-pub-4989086156410627/3939366695';
  static const String _realInterstitialIOS     = 'ca-app-pub-4989086156410627/9000121688';
  static const String _realAppOpenIOS          = 'ca-app-pub-4989086156410627/1791125207';

  // ── Platform helper ──────────────────────────────────────────
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // ── Active IDs ───────────────────────────────────────────────
  static String get appId => _useTestIds
      ? (_isAndroid ? _testAppIdAndroid : _testAppIdIOS)
      : (_isAndroid ? _realAppIdAndroid : _realAppIdIOS);

  static String get banner => _useTestIds
      ? (_isAndroid ? _testBannerAndroid : _testBannerIOS)
      : (_isAndroid ? _realBannerAndroid : _realBannerIOS);

  static String get interstitial => _useTestIds
      ? (_isAndroid ? _testInterstitialAndroid : _testInterstitialIOS)
      : (_isAndroid ? _realInterstitialAndroid : _realInterstitialIOS);

  static String get appOpen => _useTestIds
      ? (_isAndroid ? _testAppOpenAndroid : _testAppOpenIOS)
      : (_isAndroid ? _realAppOpenAndroid : _realAppOpenIOS);
}
