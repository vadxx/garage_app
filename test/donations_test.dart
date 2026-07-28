// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/pages/pages.dart';
import 'package:garage_app/providers/providers.dart';
import 'package:garage_app/urls.dart';

import 'helpers/helpers.dart';

class FakeDonationsStore implements DonationsStore {
  FakeDonationsStore({
    this.available = true,
    this.result = DonationResult.purchased,
  });

  final bool available;
  DonationResult result;
  final List<String> bought = [];

  static const prices = {
    iapDonate5: r'$5.00',
    iapDonate10: r'$10.00',
    iapDonate15: r'$15.00',
    iapDonate3monthly: r'$3.00',
  };

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<DonationProduct>> loadProducts() async => [
    for (final entry in prices.entries)
      DonationProduct(id: entry.key, price: entry.value),
  ];

  @override
  Future<DonationResult> buy(String productId) async {
    bought.add(productId);
    return result;
  }

  @override
  Future<void> dispose() async {}
}

Widget buildApp(backend.SettingsRepository repo, DonationsStore store) =>
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWith((ref) => repo),
        donationsStoreProvider.overrideWith((ref) => store),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppLocaleUtils.supportedLocales,
          home: const SettingsPage(),
        ),
      ),
    );

Future<void> openSupportSheet(WidgetTester tester) async {
  await tester.tap(find.text('Support us'));
  await tester.pumpAndSettle();
}

void main() {
  group('Donations', () {
    late FakeSettingsRepository repo;

    setUp(() {
      repo = FakeSettingsRepository();
      LocaleSettings.setLocale(AppLocale.en);
    });

    testWidgets('shows localized prices from the store', (tester) async {
      await tester.pumpWidget(buildApp(repo, FakeDonationsStore()));
      await tester.pumpAndSettle();
      await openSupportSheet(tester);

      expect(find.text(r'$5.00'), findsOneWidget);
      expect(find.text(r'$10.00'), findsOneWidget);
      expect(find.text(r'$15.00'), findsOneWidget);
      expect(find.text(r'$3.00'), findsOneWidget);
    });

    testWidgets('tapping a card buys the product and thanks the user', (
      tester,
    ) async {
      final store = FakeDonationsStore();
      await tester.pumpWidget(buildApp(repo, store));
      await tester.pumpAndSettle();
      await openSupportSheet(tester);

      await tester.tap(find.text(r'$5.00'));
      await tester.pumpAndSettle();

      expect(store.bought, [iapDonate5]);
      expect(find.text('Thank you for your support!'), findsOneWidget);
    });

    testWidgets('canceled purchase shows no snackbar', (tester) async {
      final store = FakeDonationsStore()..result = DonationResult.canceled;
      await tester.pumpWidget(buildApp(repo, store));
      await tester.pumpAndSettle();
      await openSupportSheet(tester);

      await tester.tap(find.text(r'$5.00'));
      await tester.pumpAndSettle();

      expect(store.bought, [iapDonate5]);
      expect(find.text('Thank you for your support!'), findsNothing);
      expect(find.text('Purchase could not be completed'), findsNothing);
    });

    testWidgets('failed purchase shows an error snackbar', (tester) async {
      final store = FakeDonationsStore()..result = DonationResult.error;
      await tester.pumpWidget(buildApp(repo, store));
      await tester.pumpAndSettle();
      await openSupportSheet(tester);

      await tester.tap(find.text(r'$5.00'));
      await tester.pumpAndSettle();

      expect(find.text('Purchase could not be completed'), findsOneWidget);
    });

    testWidgets('hides the donate section when billing is unavailable', (
      tester,
    ) async {
      final store = FakeDonationsStore(available: false);
      await tester.pumpWidget(buildApp(repo, store));
      await tester.pumpAndSettle();
      await openSupportSheet(tester);

      expect(find.text('Donate'), findsNothing);
      expect(find.text(r'$5'), findsNothing);
      // The rest of the sheet still shows.
      expect(find.text('Rate the app'), findsOneWidget);
    });
  });
}
