import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/app_router.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/providers/providers.dart';

class FakeSettingsRepository implements backend.SettingsRepository {
  backend.AppSettings _settings = const backend.AppSettings();
  @override
  backend.AppSettings load() => _settings;
  @override
  void save(backend.AppSettings s) => _settings = s;
}

Widget buildApp() => ProviderScope(
  overrides: [
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
  testWidgets('navigate home → settings → home', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Garage'), findsOneWidget);

    await tester.tap(find.text('⚙️'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Garage'), findsOneWidget);
  });
}
