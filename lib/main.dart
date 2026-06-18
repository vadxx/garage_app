// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'extensions/settings_extensions.dart';
import 'app_router.dart';
import 'i18n/i18n.dart';
import 'providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  runApp(ProviderScope(child: TranslationProvider(child: MainApp())));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(repositoriesProvider)
        .when(
          data: (_) => onBackendReady(ref),
          loading: () => const MaterialApp(home: SizedBox.shrink()),
          error: (e, _) =>
              MaterialApp(home: Text('${context.t.initFailed}: $e')),
        );
  }

  MaterialApp onBackendReady(WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    // Change language in background (sync slang locale). Suppress warning.
    unawaited(
      LocaleSettings.setLocale(AppLocale.values[settings.language.index]),
    );
    return MaterialApp.router(
      locale: settings.language.locale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
      themeMode: settings.theme.mode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
    );
  }
}
