// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final app = MaterialApp.router(
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
    return ref
        .watch(repositoriesProvider)
        .when(
          data: (_) => app,
          loading: () => SizedBox.shrink(),
          error: (e, _) => Text('Init failed: $e'),
        );
  }
}
