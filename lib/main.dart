// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:backend/backend.dart' as backend;

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
          data: (_) {
            final settings = ref.watch(appSettingsProvider);
            final theme = switch (settings.theme) {
              backend.Theme.light => ThemeMode.light,
              backend.Theme.system => ThemeMode.system,
              backend.Theme.dark => ThemeMode.dark,
            };
            return MaterialApp.router(
              locale: Locale(settings.language.name),
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              routerConfig: appRouter,
              themeMode: theme,
            );
          },
          loading: () => const MaterialApp(home: SizedBox.shrink()),
          error: (e, _) => MaterialApp(home: Text('Init failed: $e')),
        );
  }
}
