// ── GravitySend Ad IDs ─────────────────────────────────────────
// Replace TEST IDs with your real IDs from admob.google.com
// before building the production APK.
//
// How to get real IDs:
//   admob.google.com → Apps → Add app → Get App ID
//   admob.google.com → Ad units → Create ad unit → Get Ad Unit ID

class AdIds {
  // ── Test IDs (safe to use during development) ────────────────
  static const bool _useTestIds = true; // ← set false before prod build

  static const String _testBanner       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppId        = 'ca-app-pub-3940256099942544~3347511713';

  // ── Your Real IDs — fill these in ────────────────────────────
  static const String _realAppId        = 'ca-app-pub-4989086156410627~9173182974';
  static const String _realBanner       = 'ca-app-pub-4989086156410627/9751767477';
  static const String _realInterstitial = 'ca-app-pub-4989086156410627/9509598049';

  // ── Active IDs (switch automatically) ────────────────────────
  static String get appId        => _useTestIds ? _testAppId        : _realAppId;
  static String get banner       => _useTestIds ? _testBanner       : _realBanner;
  static String get interstitial => _useTestIds ? _testInterstitial : _realInterstitial;
}
