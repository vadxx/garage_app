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

    // Add a car with known mileage
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

    // Add a work with mileage
    worksRepo.insertWithId(
      backend.CarWork(
        id: 1,
        carId: 1,
        date: 1700000000,
        category: 0, // oil
        mileage: 50000,
        cost: 350,
        description: 'Oil change',
      ),
    );
  });

  group('CarDetailPage displays correct distance unit', () {
    testWidgets('shows km labels when unit is km', (tester) async {
      settingsRepo.save(
        const backend.AppSettings(distanceUnit: backend.DistanceUnit.km),
      );
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

      // 45000 km (last oil change) — standalone Text from subColumn
      expect(find.text('45000 km'), findsOneWidget);
      // Work card text is "2023-11-14  •  50000 km" (Text combines date + distance)
      expect(find.textContaining('50000 km'), findsOneWidget);
    });

    testWidgets('shows mi labels when unit is mi', (tester) async {
      settingsRepo.save(
        const backend.AppSettings(distanceUnit: backend.DistanceUnit.mi),
      );
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

      // 45000 km = 27961.70364 → rounds to 27962 mi
      expect(find.text('27962 mi'), findsOneWidget);
      // 50000 km = 31068.5596 → rounds to 31069 mi (in work card text)
      expect(find.textContaining('31069 mi'), findsOneWidget);
    });

    testWidgets('home page shows converted mileage', (tester) async {
      settingsRepo.save(
        const backend.AppSettings(distanceUnit: backend.DistanceUnit.mi),
      );
      await tester.pumpWidget(
        buildApp(
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // On home page, 50000 km = 31068.5596 → rounds to 31069 mi
      expect(find.text('31069 mi'), findsOneWidget);
    });
  });
}
