// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/app_router.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/providers/providers.dart';

import 'helpers/fake_cars_repository.dart';
import 'helpers/fake_settings_repository.dart';

Widget buildApp(backend.CarsRepository carsRepo) => ProviderScope(
  overrides: [
    carsRepositoryProvider.overrideWith((ref) => carsRepo),
    settingsRepositoryProvider.overrideWith((ref) => FakeSettingsRepository()),
  ],
  child: TranslationProvider(
    child: MaterialApp.router(
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    ),
  ),
);

void main() {
  group('Car CRUD flow', () {
    late FakeCarsRepository repo;

    setUp(() {
      repo = FakeCarsRepository();
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

    testWidgets('add 3 cars, edit 2nd, delete 2nd', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      // ---- Add 3 cars ----
      await addCar(tester, 'Toyota', 'Camry', '2020', 'ABC123');
      expect(repo.load().length, 1);

      await addCar(tester, 'Honda', 'Civic', '2021', 'DEF456');
      expect(repo.load().length, 2);

      await addCar(tester, 'Ford', 'Focus', '2022', 'GHI789');
      expect(repo.load().length, 3);

      // Verify home shows 3
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Honda Civic'), findsOneWidget);
      expect(find.text('Ford Focus'), findsOneWidget);

      // ---- Edit 2nd car ----
      await tester.tap(find.text('Honda Civic'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('✏️'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), 'Accord');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify 3 cars, 2nd changed, others unchanged
      expect(repo.load().length, 3);
      expect(repo.load()[1].model, 'Accord');
      expect(repo.load()[0].model, 'Camry');
      expect(repo.load()[2].model, 'Focus');

      // ---- Delete 2nd car ----
      await tester.tap(find.text('Honda Accord'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('✏️'));
      await tester.pumpAndSettle();

      // Tap delete icon button in AppBar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm dialog
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Verify 2 cars remain, 1st and 3rd
      expect(repo.load().length, 2);
      expect(repo.load()[0].make, 'Toyota');
      expect(repo.load()[1].make, 'Ford');
    });

    testWidgets('validation shows errors on empty save', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add car'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsNWidgets(6));
    });
  });
}
