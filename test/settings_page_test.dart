import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/pages/pages.dart';
import 'package:garage_app/providers/providers.dart';

class FakeSettingsRepository implements backend.SettingsRepository {
  backend.AppSettings _settings = const backend.AppSettings();
  @override
  backend.AppSettings load() => _settings;
  @override
  void save(backend.AppSettings s) => _settings = s;
}

Widget buildApp(backend.SettingsRepository repo) => ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWith((ref) => repo),
  ],
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
    });

    testWidgets('shows theme, language, currency changers', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('changing theme updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<backend.Theme>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(repo.load().theme, backend.Theme.dark);
    });

    testWidgets('changing language updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<backend.Language>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Russian').last);
      await tester.pumpAndSettle();

      expect(repo.load().language, backend.Language.ru);
    });

    testWidgets('changing currency updates provider state', (tester) async {
      await tester.pumpWidget(buildApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<backend.Currency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR').last);
      await tester.pumpAndSettle();

      expect(repo.load().currency, backend.Currency.eur);
    });
  });
}
