// ── GravitySend Ad IDs ─────────────────────────────────────────
// Real IDs are active. Test IDs can be re-enabled by setting
// _useTestIds = true during development.
//
// Real IDs sourced from admob.google.com:
//   App ID:        ca-app-pub-4989086156410627~9173182974
//   Banner:        ca-app-pub-4989086156410627/9751767477  (GS_Android_Banner)
//   Interstitial:  ca-app-pub-4989086156410627/9509598049  (GS_Android_Interstitial)


import 'package:flutter/foundation.dart';

class AdIds {
  // ── Toggle: automatically use test IDs in debug mode ─
  static const bool _useTestIds = true; // Set to true to use test ads during dev

  // ── Google Official Test IDs ─────────────────────────────────
  // Android Test IDs
  static const String _testBannerAndroid       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppIdAndroid        = 'ca-app-pub-3940256099942544~3347511713';
  
  // iOS Test IDs
  static const String _testBannerIOS       = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testAppIdIOS        = 'ca-app-pub-3940256099942544~1458002511';

  // ── Production IDs (from admob.google.com) ───────────────────
  // Android Real IDs
  static const String _realAppIdAndroid        = 'ca-app-pub-4989086156410627~9173182974';
  static const String _realBannerAndroid       = 'ca-app-pub-4989086156410627/9751767477';
  static const String _realInterstitialAndroid = 'ca-app-pub-4989086156410627/9509598049';

  // iOS Real IDs (TODO: User needs to replace these with real iOS IDs)
  static const String _realAppIdIOS        = 'ca-app-pub-4989086156410627~2590891937';
  static const String _realBannerIOS       = 'ca-app-pub-4989086156410627/3939366695';
  static const String _realInterstitialIOS = 'ca-app-pub-4989086156410627/9000121688';

  // Helper to determine if we should use Android or iOS IDs
  // This avoids dart:io to ensure Flutter Web compatibility.
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // ── Active IDs — switches automatically based on _useTestIds ─
  static String get appId => _useTestIds 
      ? (_isAndroid ? _testAppIdAndroid : _testAppIdIOS)
      : (_isAndroid ? _realAppIdAndroid : _realAppIdIOS);

  static String get banner => _useTestIds 
      ? (_isAndroid ? _testBannerAndroid : _testBannerIOS)
      : (_isAndroid ? _realBannerAndroid : _realBannerIOS);

  static String get interstitial => _useTestIds 
      ? (_isAndroid ? _testInterstitialAndroid : _testInterstitialIOS)
      : (_isAndroid ? _realInterstitialAndroid : _realInterstitialIOS);
}
