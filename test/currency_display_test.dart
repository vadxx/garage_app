// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/app_router.dart';

import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/pages/pages.dart';
import 'package:garage_app/providers/providers.dart';

import 'helpers/helpers.dart';

Widget buildApp({
  required backend.SettingsRepository settingsRepo,
  required backend.CarsRepository carsRepo,
}) => ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWith((ref) => settingsRepo),
    carsRepositoryProvider.overrideWith((ref) => carsRepo),
  ],
  child: TranslationProvider(
    child: MaterialApp.router(
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    ),
  ),
);

final _car = backend.Car(
  id: 0,
  year: 2020,
  color: 0,
  price: 5000,
  mileage: 30000,
  make: 'Toyota',
  model: 'Camry',
  plate: 'ABC123',
);

void main() {
  group('HomePage currency display', () {
    late FakeCarsRepository carsRepo;
    late FakeSettingsRepository settingsRepo;

    setUp(() {
      carsRepo = FakeCarsRepository();
      settingsRepo = FakeSettingsRepository();
      LocaleSettings.setLocale(AppLocale.en);
    });

    testWidgets('default USD shows dollar sign', (tester) async {
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(carId: _car.id, totalSpent: 8420, lastOilChangeKm: 0),
      );
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.usd),
      );

      await tester.pumpWidget(
        buildApp(settingsRepo: settingsRepo, carsRepo: carsRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$5000'), findsOneWidget);
      expect(find.text(r'$8420'), findsOneWidget);
    });

    testWidgets('RUB setting shows ruble symbol', (tester) async {
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(carId: _car.id, totalSpent: 8420, lastOilChangeKm: 0),
      );
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );

      await tester.pumpWidget(
        buildApp(settingsRepo: settingsRepo, carsRepo: carsRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('425000 ₽'), findsOneWidget);
      expect(find.text('715700 ₽'), findsOneWidget);
    });

    testWidgets('EUR setting shows euro symbol', (tester) async {
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(carId: _car.id, totalSpent: 8420, lastOilChangeKm: 0),
      );
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.eur),
      );

      await tester.pumpWidget(
        buildApp(settingsRepo: settingsRepo, carsRepo: carsRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('€4600'), findsOneWidget);
      expect(find.text('€7746'), findsOneWidget);
    });

    testWidgets('changing currency on settings page updates home display', (
      tester,
    ) async {
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(carId: _car.id, totalSpent: 8420, lastOilChangeKm: 0),
      );
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.usd),
      );

      await tester.pumpWidget(
        buildApp(settingsRepo: settingsRepo, carsRepo: carsRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$5000'), findsOneWidget);

      await tester.tap(find.text('⚙️'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('💵 Currency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('€4600'), findsOneWidget);
      expect(find.text(r'$5000'), findsNothing);
    });
  });

  group('CarDetailPage currency display', () {
    Widget buildDetailApp({
      required backend.Currency currency,
      required backend.CarsRepository carsRepo,
      required backend.CarWorksRepository worksRepo,
      required backend.SettingsRepository settingsRepo,
    }) {
      return ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWith((ref) => settingsRepo),
          carsRepositoryProvider.overrideWith((ref) => carsRepo),
          carWorksRepositoryProvider.overrideWith((ref) => worksRepo),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: CarDetailPage(carId: _car.id),
          ),
        ),
      );
    }

    testWidgets('shows USD on car detail', (tester) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.usd),
      );
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(
          carId: _car.id,
          totalSpent: 8420,
          lastOilChangeKm: 30000,
        ),
      );
      worksRepo.insert(
        backend.CarWork(
          id: 0,
          carId: _car.id,
          date: 1700000000,
          category: 0,
          mileage: 35000,
          cost: 350,
          description: 'Oil change',
        ),
      );

      await tester.pumpWidget(
        buildDetailApp(
          currency: backend.Currency.usd,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
          settingsRepo: settingsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$8420'), findsOneWidget);
      expect(find.text(r'$350'), findsOneWidget);
    });

    testWidgets('shows RUB on car detail', (tester) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(
          carId: _car.id,
          totalSpent: 8420,
          lastOilChangeKm: 30000,
        ),
      );
      worksRepo.insert(
        backend.CarWork(
          id: 0,
          carId: _car.id,
          date: 1700000000,
          category: 0,
          mileage: 35000,
          cost: 350,
          description: 'Oil change',
        ),
      );

      await tester.pumpWidget(
        buildDetailApp(
          currency: backend.Currency.rub,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
          settingsRepo: settingsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('715700 ₽'), findsOneWidget);
      expect(find.text('29750 ₽'), findsOneWidget);
    });

    testWidgets('shows EUR on car detail', (tester) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.eur),
      );
      carsRepo.insertWithId(_car);
      carsRepo.saveCarStats(
        backend.CarStats(
          carId: _car.id,
          totalSpent: 8420,
          lastOilChangeKm: 30000,
        ),
      );
      worksRepo.insert(
        backend.CarWork(
          id: 0,
          carId: _car.id,
          date: 1700000000,
          category: 0,
          mileage: 35000,
          cost: 350,
          description: 'Oil change',
        ),
      );

      await tester.pumpWidget(
        buildDetailApp(
          currency: backend.Currency.eur,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
          settingsRepo: settingsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('€7746'), findsOneWidget);
      expect(find.text('€322'), findsOneWidget);
    });
  });
}
