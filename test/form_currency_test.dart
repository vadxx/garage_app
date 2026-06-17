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

import 'helpers/helpers.dart';

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

final _workCar = backend.Car(
  id: 1,
  year: 2020,
  color: 0,
  price: 10000,
  mileage: 50000,
  make: 'Honda',
  model: 'Civic',
  plate: 'DEF456',
);

Widget buildFormApp({
  required Widget home,
  required backend.SettingsRepository settingsRepo,
  required backend.CarsRepository carsRepo,
  backend.CarWorksRepository? worksRepo,
}) {
  final overrides = <Override>[
    settingsRepositoryProvider.overrideWith((ref) => settingsRepo),
    carsRepositoryProvider.overrideWith((ref) => carsRepo),
  ];
  if (worksRepo != null) {
    overrides.add(carWorksRepositoryProvider.overrideWith((ref) => worksRepo));
  }
  return ProviderScope(
    overrides: overrides,
    child: TranslationProvider(
      child: MaterialApp(
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: home,
      ),
    ),
  );
}

Future<TextField> findTextField(WidgetTester tester, String label) async {
  // TextFields with labels show a TextFormField with a label Text widget
  final labelFinder = find.text(label);
  expect(labelFinder, findsOneWidget, reason: 'Label "$label" should exist');
  // The TextField is the FormField ancestor of the label
  final fieldFinder = find.ancestor(
    of: labelFinder,
    matching: find.byType(TextField),
  );
  expect(
    fieldFinder,
    findsOneWidget,
    reason: 'TextField for "$label" should exist',
  );
  return tester.widget<TextField>(fieldFinder);
}

void main() {
  group('AddEditCarPage currency', () {
    testWidgets('price field shows USD symbol when currency is USD', (
      tester,
    ) async {
      final carsRepo = FakeCarsRepository();
      final settingsRepo = FakeSettingsRepository();
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.usd),
      );

      await tester.pumpWidget(
        buildFormApp(
          home: const AddEditCarPage(),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price (\$)'), findsOneWidget);
    });

    testWidgets('price field shows RUB symbol when currency is RUB', (
      tester,
    ) async {
      final carsRepo = FakeCarsRepository();
      final settingsRepo = FakeSettingsRepository();
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );

      await tester.pumpWidget(
        buildFormApp(
          home: const AddEditCarPage(),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price (₽)'), findsOneWidget);
    });

    testWidgets('price field shows EUR symbol when currency is EUR', (
      tester,
    ) async {
      final carsRepo = FakeCarsRepository();
      final settingsRepo = FakeSettingsRepository();
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.eur),
      );

      await tester.pumpWidget(
        buildFormApp(
          home: const AddEditCarPage(),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price (€)'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills price converted to RUB', (tester) async {
      final carsRepo = FakeCarsRepository();
      final settingsRepo = FakeSettingsRepository();

      // Store $5000 USD, user has RUB selected
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );
      carsRepo.insertWithId(_car);

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarPage(carId: _car.id),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
        ),
      );
      await tester.pumpAndSettle();

      // $5000 USD → 5000 * 85 = 425000 RUB
      final field = await findTextField(tester, 'Price (₽)');
      expect(field.controller?.text, '425000');
    });

    testWidgets('edit mode pre-fills price converted to EUR', (tester) async {
      final carsRepo = FakeCarsRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.eur),
      );
      carsRepo.insertWithId(_car);

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarPage(carId: _car.id),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
        ),
      );
      await tester.pumpAndSettle();

      // $5000 USD → 5000 * 0.92 = 4600 EUR
      final field = await findTextField(tester, 'Price (€)');
      expect(field.controller?.text, '4600');
    });
  });

  group('AddEditCarWorkPage currency', () {
    testWidgets('cost field shows USD symbol when currency is USD', (
      tester,
    ) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.usd),
      );
      carsRepo.insertWithId(_workCar);

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarWorkPage(carId: _workCar.id),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price (\$)'), findsOneWidget);
    });

    testWidgets('cost field shows RUB symbol when currency is RUB', (
      tester,
    ) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();
      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );
      carsRepo.insertWithId(_workCar);

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarWorkPage(carId: _workCar.id),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price (₽)'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills cost converted to RUB', (tester) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.rub),
      );
      carsRepo.insertWithId(_workCar);
      worksRepo.insertWithId(
        backend.CarWork(
          id: 0,
          carId: _workCar.id,
          date: 1700000000,
          category: 0,
          mileage: 35000,
          cost: 350,
          description: 'Oil change',
        ),
      );

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarWorkPage(carId: _workCar.id, workId: 0),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // $350 USD → 350 * 85 = 29750 RUB
      final field = await findTextField(tester, 'Price (₽)');
      expect(field.controller?.text, '29750');
    });

    testWidgets('edit mode pre-fills cost converted to EUR', (tester) async {
      final carsRepo = FakeCarsRepository();
      final worksRepo = FakeCarWorksRepository();
      final settingsRepo = FakeSettingsRepository();

      settingsRepo.save(
        const backend.AppSettings(currency: backend.Currency.eur),
      );
      carsRepo.insertWithId(_workCar);
      worksRepo.insertWithId(
        backend.CarWork(
          id: 0,
          carId: _workCar.id,
          date: 1700000000,
          category: 0,
          mileage: 35000,
          cost: 350,
          description: 'Oil change',
        ),
      );

      await tester.pumpWidget(
        buildFormApp(
          home: AddEditCarWorkPage(carId: _workCar.id, workId: 0),
          settingsRepo: settingsRepo,
          carsRepo: carsRepo,
          worksRepo: worksRepo,
        ),
      );
      await tester.pumpAndSettle();

      // $350 USD → 350 * 0.92 = 322 EUR
      final field = await findTextField(tester, 'Price (€)');
      expect(field.controller?.text, '322');
    });
  });
}
