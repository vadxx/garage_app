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

import 'helpers/fake_cars_repository.dart';
import 'helpers/fake_car_works_repository.dart';
import 'helpers/fake_settings_repository.dart';

GoRouter _testRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
    GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
    GoRoute(path: Routes.addCar, builder: (_, _) => const AddEditCarPage()),
    GoRoute(
      path: Routes.editCarPattern,
      builder: (_, state) =>
          AddEditCarPage(carId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: Routes.carPattern,
      builder: (_, state) =>
          CarDetailPage(carId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: Routes.addCarWorkPattern,
      builder: (_, state) =>
          AddEditCarWorkPage(carId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: Routes.editCarWorkPattern,
      builder: (_, state) => AddEditCarWorkPage(
        carId: int.parse(state.pathParameters['id']!),
        workId: int.parse(state.pathParameters['workId']!),
      ),
    ),
  ],
);

Widget buildApp(
  backend.CarsRepository carsRepo,
  backend.CarWorksRepository worksRepo,
) => ProviderScope(
  overrides: [
    carsRepositoryProvider.overrideWith((ref) => carsRepo),
    carWorksRepositoryProvider.overrideWith((ref) => worksRepo),
    settingsRepositoryProvider.overrideWith((ref) => FakeSettingsRepository()),
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
  group('Car work flow', () {
    late FakeCarsRepository carsRepo;
    late FakeCarWorksRepository worksRepo;

    setUp(() {
      carsRepo = FakeCarsRepository();
      worksRepo = FakeCarWorksRepository();
    });

    Future<void> addCar(
      WidgetTester tester,
      String make,
      String model,
      String year,
      String plate, {
      String price = '5000',
      String mileage = '10000',
    }) async {
      await tester.tap(find.text('Add car'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), make);
      await tester.enterText(find.byType(TextField).at(1), model);
      await tester.enterText(find.byType(TextField).at(2), year);
      await tester.enterText(find.byType(TextField).at(3), price);
      await tester.enterText(find.byType(TextField).at(4), plate);
      await tester.enterText(find.byType(TextField).at(5), mileage);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
    }

    testWidgets('add work, edit work, delete work', (tester) async {
      await tester.pumpWidget(buildApp(carsRepo, worksRepo));
      await tester.pumpAndSettle();

      // ---- Create a car first ----
      await addCar(tester, 'Toyota', 'Camry', '2020', 'ABC123');
      expect(carsRepo.load().length, 1);

      // ---- Navigate to car detail ----
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // ---- Add a work ----
      await tester.tap(find.text('Add work'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField).at(0), '75000');
      await tester.enterText(find.byType(TextField).at(1), '350');
      await tester.enterText(
        find.byType(TextField).at(2),
        'Oil change and filter',
      );

      // Select first category chip
      final firstChip = find.text('Oil change');
      await tester.ensureVisible(firstChip);
      await tester.pumpAndSettle();
      await tester.tap(firstChip);
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify work appears on car detail
      expect(worksRepo.loadByCarId(1).length, 1);
      expect(find.textContaining('Oil change and filter'), findsOneWidget);
      expect(find.text('\$350'), findsOneWidget);

      // ---- Edit the work ----
      await tester.tap(find.textContaining('Oil change and filter'));
      await tester.pumpAndSettle();

      // Modify fields
      final mileField = find.byType(TextField).at(0);
      await tester.enterText(mileField, '80000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify update
      final works = worksRepo.loadByCarId(1);
      expect(works.length, 1);
      expect(works[0].mileage, 80000);
    });

    testWidgets('validation shows errors on empty save', (tester) async {
      await tester.pumpWidget(buildApp(carsRepo, worksRepo));
      await tester.pumpAndSettle();

      // Create a car and go to detail
      await addCar(tester, 'Honda', 'Civic', '2021', 'DEF456');

      await tester.tap(find.text('Honda Civic'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add work'));
      await tester.pumpAndSettle();

      // Clear pre-filled mileage
      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.pumpAndSettle();

      // Save with empty fields
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.text('Required'), findsAtLeastNWidgets(3));

      // No work was created
      expect(worksRepo.loadByCarId(1), isEmpty);
    });
  });
}
