// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../urls.dart';

/// A donation product with its localized price label.
class DonationProduct {
  const DonationProduct({required this.id, required this.price});

  final String id;
  final String price;
}

/// Final outcome of a purchase flow.
enum DonationResult { purchased, canceled, error }

/// Thin abstraction over the billing store so widget tests can inject a fake.
abstract class DonationsStore {
  Future<bool> isAvailable();
  Future<List<DonationProduct>> loadProducts();

  /// Starts the purchase flow for [productId] and resolves with its result.
  Future<DonationResult> buy(String productId);
  Future<void> dispose();
}

/// Store implementation backed by the in_app_purchase plugin.
class InAppPurchaseStore implements DonationsStore {
  InAppPurchaseStore() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(_onUpdates);
  }

  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  final Map<String, ProductDetails> _products = {};
  final Map<String, Completer<DonationResult>> _pending = {};

  @override
  Future<bool> isAvailable() => InAppPurchase.instance.isAvailable();

  @override
  Future<List<DonationProduct>> loadProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(
      donationProductIds,
    );
    if (response.error != null) return [];
    _products
      ..clear()
      ..addEntries(response.productDetails.map((p) => MapEntry(p.id, p)));
    return [
      for (final p in response.productDetails)
        DonationProduct(id: p.id, price: p.price),
    ];
  }

  @override
  Future<DonationResult> buy(String productId) async {
    final details = _products[productId];
    if (details == null) return DonationResult.error;
    final completer = Completer<DonationResult>();
    _pending[productId] = completer;
    final param = PurchaseParam(productDetails: details);
    try {
      // The monthly donation is a subscription; one-time donations must be
      // bought as consumables so the user can donate repeatedly.
      final launched = productId == iapDonate3monthly
          ? await InAppPurchase.instance.buyNonConsumable(purchaseParam: param)
          : await InAppPurchase.instance.buyConsumable(purchaseParam: param);
      if (!launched) {
        _pending.remove(productId);
        return DonationResult.error;
      }
    } catch (_) {
      _pending.remove(productId);
      return DonationResult.error;
    }
    return completer.future;
  }

  void _onUpdates(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _finish(p.productID, DonationResult.purchased);
        case PurchaseStatus.error:
          _finish(p.productID, DonationResult.error);
        case PurchaseStatus.canceled:
          _finish(p.productID, DonationResult.canceled);
      }
      if (p.pendingCompletePurchase) {
        // Completes (consumes/acknowledges) the purchase on the store side.
        InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  void _finish(String productId, DonationResult result) {
    final completer = _pending.remove(productId);
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  @override
  Future<void> dispose() => _subscription.cancel();
}

/// Store used on platforms without billing support (e.g. Windows).
class UnavailableDonationsStore implements DonationsStore {
  const UnavailableDonationsStore();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<List<DonationProduct>> loadProducts() async => [];

  @override
  Future<DonationResult> buy(String productId) async => DonationResult.error;

  @override
  Future<void> dispose() async {}
}

final donationsStoreProvider = Provider<DonationsStore>((ref) {
  final store = Platform.isAndroid || Platform.isIOS
      ? InAppPurchaseStore()
      : const UnavailableDonationsStore();
  ref.onDispose(store.dispose);
  return store;
});

class DonationsState {
  const DonationsState({required this.available, required this.products});

  final bool available;
  final Map<String, DonationProduct> products;
}

final donationsProvider =
    AsyncNotifierProvider<DonationsNotifier, DonationsState>(
      DonationsNotifier.new,
    );

class DonationsNotifier extends AsyncNotifier<DonationsState> {
  @override
  Future<DonationsState> build() async {
    final store = ref.watch(donationsStoreProvider);
    if (!await store.isAvailable()) {
      return const DonationsState(available: false, products: {});
    }
    final products = await store.loadProducts();
    return DonationsState(
      available: true,
      products: {for (final p in products) p.id: p},
    );
  }

  Future<DonationResult> buy(String productId) =>
      ref.read(donationsStoreProvider).buy(productId);
}
