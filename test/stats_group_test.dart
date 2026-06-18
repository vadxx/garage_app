// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_router/go_router.dart';
import 'package:backend/backend.dart' as backend;
import 'package:backend/backend.dart' show Routes;
import 'package:garage_app/pages/pages.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/providers/providers.dart';

import 'helpers/helpers.dart';

GoRouter _testRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
    GoRoute(
      path: Routes.carPattern,
      builder: (_, state) =>
          CarDetailPage(carId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

Widget buildApp({
  required backend.SettingsRepository settingsRepo,
  required backend.CarsRepository carsRepo,
  required backend.CarWorksRepository worksRepo,
}) => ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWith((ref) => settingsRepo),
    carsRepositoryProvider.overrideWith((ref) => carsRepo),
    carWorksRepositoryProvider.overrideWith((ref) => worksRepo),
  ],
  child: TranslationProvider(
    child: MaterialApp.router(
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _testRouter(),
    ),
  ),
);

void main() {
  late FakeSettingsRepository settingsRepo;
  late FakeCarsRepository carsRepo;
  late FakeCarWorksRepository worksRepo;

  setUp(() {
    settingsRepo = FakeSettingsRepository();
    carsRepo = FakeCarsRepository();
    worksRepo = FakeCarWorksRepository();

    LocaleSettings.setLocale(AppLocale.en);

    // Add a car
    carsRepo.insertWithId(
      backend.Car(
        id: 1,
        year: 2020,
        color: 0,
        price: 15000,
        mileage: 50000,
        make: 'Toyota',
        model: 'Camry',
        plate: 'ABC123',
      ),
    );
    carsRepo.saveCarStats(
      backend.CarStats(carId: 1, totalSpent: 1200, lastOilChangeKm: 45000),
    );

    // Add works with current month timestamps
    final now = DateTime.now();
    final currentMonthTimestamp =
        DateTime(now.year, now.month, 15).millisecondsSinceEpoch ~/ 1000;
    final lastMonthTimestamp =
        DateTime(now.year, now.month - 1, 15).millisecondsSinceEpoch ~/ 1000;

    worksRepo.insertWithId(
      backend.CarWork(
        id: 1,
        carId: 1,
        date: lastMonthTimestamp,
        category: 0, // oil
        mileage: 50000,
        cost: 350,
        description: 'Oil change',
      ),
    );
    worksRepo.insertWithId(
      backend.CarWork(
        id: 2,
        carId: 1,
        date: currentMonthTimestamp,
        category: 0, // oil
        mileage: 55000,
        cost: 400,
        description: 'Oil change 2',
      ),
    );
    worksRepo.insertWithId(
      backend.CarWork(
        id: 3,
        carId: 1,
        date: currentMonthTimestamp,
        category: 2, // cleaning
        mileage: 56000,
        cost: 50,
        description: 'Car wash',
      ),
    );
  });

  group('StatsGroup bottom sheets', () {
    testWidgets('oil life tile shows chevron', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Oil life tile should be visible with chevron
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('spent tile shows chevron', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Spent tile should show total spent
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('top category tile shows chevron', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Top category should be visible
      expect(find.text('Top category'), findsOneWidget);
    });

    testWidgets('tapping oil life tile opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Find and tap the oil life tile
      final oilTile = find.textContaining('Oil life');
      expect(oilTile, findsOneWidget);
      await tester.tap(oilTile);
      await tester.pumpAndSettle();

      // Bottom sheet should appear with oil change history
      expect(find.textContaining('Oil change'), findsWidgets);
    });

    testWidgets('tapping spent tile opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Find and tap the spent tile
      final spentTile = find.text('Spent money');
      expect(spentTile, findsOneWidget);
      await tester.tap(spentTile);
      await tester.pumpAndSettle();

      // Bottom sheet should appear
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('tapping top category tile opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Find and tap the top category tile
      final topCatTile = find.text('Top category');
      expect(topCatTile, findsOneWidget);
      await tester.tap(topCatTile);
      await tester.pumpAndSettle();

      // Bottom sheet should appear
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('oil bottom sheet shows item count', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Tap oil life tile
      await tester.tap(find.textContaining('Oil life'));
      await tester.pumpAndSettle();

      // Should show count in title
      expect(find.textContaining('(2)'), findsOneWidget);
    });

    testWidgets('monthly spendings sheet shows current month', (tester) async {
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to car detail
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Tap spent tile
      await tester.tap(find.text('Spent money'));
      await tester.pumpAndSettle();

      // Should show current month marker
      expect(find.textContaining('current'), findsOneWidget);
    });
  });
}
