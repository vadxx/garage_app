import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:garage_app/app_router.dart';
import 'package:garage_app/i18n/i18n.dart';

void main() {
  testWidgets('navigate home → settings → home', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: appRouter,
        ),
      ),
    );

    expect(find.text('Garage'), findsOneWidget);

    await tester.tap(find.text('⚙️'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('🡰'));
    await tester.pumpAndSettle();

    expect(find.text('Garage'), findsOneWidget);
  });
}
