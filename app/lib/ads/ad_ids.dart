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
  static const bool _useTestIds = kDebugMode; // Auto-switches to false in Release

  // ── Google Official Test IDs ─────────────────────────────────
  static const String _testBanner       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppId        = 'ca-app-pub-3940256099942544~3347511713';

  // ── Production IDs (from admob.google.com) ───────────────────
  static const String _realAppId        = 'ca-app-pub-4989086156410627~9173182974';
  static const String _realBanner       = 'ca-app-pub-4989086156410627/9751767477';
  static const String _realInterstitial = 'ca-app-pub-4989086156410627/9509598049';

  // ── Active IDs — switches automatically based on _useTestIds ─
  static String get appId        => _useTestIds ? _testAppId        : _realAppId;
  static String get banner       => _useTestIds ? _testBanner       : _realBanner;
  static String get interstitial => _useTestIds ? _testInterstitial : _realInterstitial;
}
