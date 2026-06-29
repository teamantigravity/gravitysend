import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';
import 'package:gravitysend_app/model/state/purchase_state.dart';
import 'package:gravitysend_app/provider/purchase_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:refena_flutter/refena_flutter.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});
  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  ProductDetails? _product;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProduct());
  }

  Future<void> _loadProduct() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      if (mounted) setState(() { _loading = false; _error = 'Store unavailable'; });
      return;
    }
    final productId = PurchaseItem.removeAds.platformProductId;
    final response = await InAppPurchase.instance.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Product not found (${response.error?.message ?? 'check Play/App Store console'})';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _product = response.productDetails.first;
        _loading = false;
      });
    }
  }

  Future<void> _buy() async {
    final product = _product;
    if (product == null) return;
    setState(() => _purchasing = true);
    try {
      // Uses purchase_provider.dart's _HandlePurchaseUpdate to handle the result.
      // No local listener needed — purchase_provider handles stream globally.
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _purchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Watch purchase state — if removeAds is in purchases, user is now ad-free
    final purchaseState = context.ref.watch(purchaseProvider);
    final isAdFree = AdManager.isAdFree || purchaseState.purchases.contains(PurchaseItem.removeAds);

    // If purchase was just confirmed, update AdManager and pop
    if (isAdFree && mounted && !_purchasing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ads removed. Thank you! ⚡')),
          );
          Navigator.of(context).maybePop();
        }
      });
    }

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
              Icon(Icons.bolt, size: 72, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                'Gravity Send Pro',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Remove ads & support development.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Feature list ──────────────────────────────────
              ...[
                ('No banner ads',             Icons.hide_image_outlined),
                ('No interstitial ads',        Icons.block),
                ('No app-open ads',            Icons.ads_click),
                ('Supports the developer',     Icons.favorite_outline),
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  Icon(item.$2, color: scheme.primary, size: 22),
                  const SizedBox(width: 14),
                  Text(item.$1, style: Theme.of(context).textTheme.bodyLarge),
                ]),
              )),

              const Spacer(),

              // ── Buy button ────────────────────────────────────
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                )
              else
                FilledButton(
                  onPressed: _purchasing ? null : _buy,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _purchasing
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    // Price always comes from the real store — no hardcoded fallback
                    : Text(
                        'Remove Ads — ${_product!.price}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
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
