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

Widget buildApp(backend.SettingsRepository repo) => ProviderScope(
  overrides: [settingsRepositoryProvider.overrideWith((ref) => repo)],
  child: TranslationProvider(
    child: MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      home: const SettingsPage(),
    ),
  ),
);

void main() {
  group('SettingsPage', () {
    late FakeSettingsRepository repo;

    setUp(() {
      repo = FakeSettingsRepository();
      LocaleSettings.setLocale(AppLocale.en);
    });

    testWidgets('shows theme, language, currency, mileage changers', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('🎨 Theme'), findsOneWidget);
      expect(find.text('🌐 Language'), findsOneWidget);
      expect(find.text('💵 Currency'), findsOneWidget);
      expect(find.text('📏 Mileage'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('Kilometers'), findsOneWidget);
    });

    testWidgets('changing theme updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🎨 Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(repo.load().theme, backend.Theme.dark);
    });

    testWidgets('changing language updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🌐 Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Russian'));
      await tester.pumpAndSettle();

      expect(repo.load().language, backend.Language.ru);
    });

    testWidgets('changing currency updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('💵 Currency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();

      expect(repo.load().currency, backend.Currency.eur);
    });

    testWidgets('changing mileage updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('📏 Mileage'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Miles'));
      await tester.pumpAndSettle();

      expect(repo.load().distanceUnit, backend.DistanceUnit.mi);
    });
  });
}
