// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

import '../providers/providers.dart';
import 'package:backend/backend.dart' as backend;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = context.t.settings;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToHome(context)),
        title: Text(title),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          _ThemeChanger(),
          _LanguageChanger(),
          _CurrencyChanger(),
          _MileageChanger(),
        ],
      ),
    );
  }
}

// TODO: Refactor
class _ThemeChanger extends ConsumerWidget {
  const _ThemeChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return ListTile(
      title: Text('🎨 ${context.t.theme}'),
      trailing: DropdownButton<backend.Theme>(
        value: settings.theme,
        items: [
          DropdownMenuItem(
            value: backend.Theme.system,
            child: Text(context.t.system),
          ),
          DropdownMenuItem(
            value: backend.Theme.light,
            child: Text(context.t.light),
          ),
          DropdownMenuItem(
            value: backend.Theme.dark,
            child: Text(context.t.dark),
          ),
        ],
        onChanged: (v) => ref.read(appSettingsProvider.notifier).setTheme(v!),
      ),
    );
  }
}

// TODO: Refactor
class _LanguageChanger extends ConsumerWidget {
  const _LanguageChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return ListTile(
      title: Text('🌐 ${context.t.language}'),
      trailing: DropdownButton<backend.Language>(
        value: settings.language,
        items: [
          DropdownMenuItem(
            value: backend.Language.en,
            child: Text(context.t.en),
          ),
          DropdownMenuItem(
            value: backend.Language.ru,
            child: Text(context.t.ru),
          ),
        ],
        onChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setLanguage(v!),
      ),
    );
  }
}

// TODO: Refactor
class _CurrencyChanger extends ConsumerWidget {
  const _CurrencyChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return ListTile(
      title: Text('💵 ${context.t.currency}'),
      trailing: DropdownButton<backend.Currency>(
        value: settings.currency,
        items: [
          DropdownMenuItem(
            value: backend.Currency.usd,
            child: Text(context.t.usd),
          ),
          DropdownMenuItem(
            value: backend.Currency.rub,
            child: Text(context.t.rub),
          ),
          DropdownMenuItem(
            value: backend.Currency.eur,
            child: Text(context.t.eur),
          ),
        ],
        onChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setCurrency(v!),
      ),
    );
  }
}

// TODO: Refactor
class _MileageChanger extends ConsumerWidget {
  const _MileageChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return ListTile(
      title: Text('📏 ${context.t.mileage}'),
      trailing: DropdownButton<backend.DistanceUnit>(
        value: settings.distanceUnit,
        items: [
          DropdownMenuItem(
            value: backend.DistanceUnit.km,
            child: Text(context.t.km),
          ),
          DropdownMenuItem(
            value: backend.DistanceUnit.mi,
            child: Text(context.t.mi),
          ),
        ],
        onChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setDistanceUnit(v!),
      ),
    );
  }
}
