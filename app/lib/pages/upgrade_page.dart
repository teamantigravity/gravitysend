import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Register this product ID as a ONE-TIME purchase in Google Play Console
// and App Store Connect (when you have iOS):
const String kRemoveAdsProductId = 'gravitysend_remove_ads';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});
  @override State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  final InAppPurchase _iap   = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails?    _product;
  bool               _loading = true;
  bool               _purchasing = false;
  String?            _error;

  @override
  void initState() {
    super.initState();
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);
    unawaited(_loadProduct());
  }

  Future<void> _loadProduct() async {
    final available = await _iap.isAvailable();
    if (!available) {
      if (mounted) setState(() { _loading = false; _error = 'Store unavailable'; });
      return;
    }
    final response = await _iap.queryProductDetails({kRemoveAdsProductId});
    if (response.productDetails.isEmpty) {
      if (mounted) setState(() { _loading = false; _error = 'Product not found'; });
      return;
    }
    if (mounted) setState(() { _product = response.productDetails.first; _loading = false; });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.productID == kRemoveAdsProductId) {
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          unawaited(AdManager.setAdFree(true));
          unawaited(_iap.completePurchase(p));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ads removed. Thank you! ⚡')),
            );
            Navigator.of(context).pop();
          }
        } else if (p.status == PurchaseStatus.error) {
          if (mounted) setState(() => _purchasing = false);
          unawaited(_iap.completePurchase(p));
        }
      }
    }
  }

  Future<void> _buy() async {
    if (_product == null) return;
    setState(() => _purchasing = true);
    unawaited(_iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: _product!),
    ));
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    unawaited(_iap.restorePurchases());
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Ads'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero ──────────────────────────────────────────
              Icon(Icons.bolt, size: 72, color: scheme.primary),
              const SizedBox(height: 16),
              Text('GravitySend Pro',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('One-time purchase. Ads removed forever.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Feature list ──────────────────────────────────
              ...[
                ('No banner ads',             Icons.hide_image_outlined),
                ('No interstitial ads',        Icons.block),
                ('Unlimited transfer history', Icons.history),
                ('Supports the developer',     Icons.favorite_outline),
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  Icon(item.$2, color: scheme.primary, size: 22),
                  const SizedBox(width: 14),
                  Text(item.$1,
                    style: Theme.of(context).textTheme.bodyLarge),
                ]),
              )),

              const Spacer(),

              // ── Buy button ────────────────────────────────────
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Text(_error!, textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error))
              else
                FilledButton(
                  onPressed: _purchasing ? null : _buy,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _purchasing
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,
                          color: Colors.white))
                    : Text('Remove Ads — ${_product?.price ?? '\$1.99'}',
                        style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _restore,
                child: const Text('Restore previous purchase'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
