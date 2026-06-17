// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

import '../providers/providers.dart';
import 'package:backend/backend.dart' as backend;
import 'helpers.dart' as helpers;

Future<T?> _showSettingDialog<T>(
  BuildContext context, {
  required String emoji,
  required String title,
  required T current,
  required List<(T, String)> items,
}) {
  final primaryColor = Theme.of(context).colorScheme.primary;
  return showDialog<T>(
    context: context,
    builder: (ctx) => helpers.styledDialog(
      title: Text(
        '$emoji $title',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final selected = item.$1 == current;
          final icon = Icon(
            selected ? Icons.circle : Icons.circle_outlined,
            size: 20,
            color: selected ? primaryColor : null,
          );
          final border = BoxDecoration(
            color: selected ? primaryColor.withAlpha(15) : null,
            borderRadius: BorderRadius.circular(8),
          );
          final textStyle = TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w600 : null,
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Ink(
              decoration: border,
              child: ListTile(
                leading: icon,
                title: Text(item.$2, style: textStyle),
                onTap: () => Navigator.pop(ctx, item.$1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                dense: true,
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

BoxDecoration _outlinedBorder(BuildContext context) => BoxDecoration(
  border: Border.fromBorderSide(
    BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
  ),
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.value, this.onTap});
  final Widget title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = [
      Text(value, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 4),
      const Icon(Icons.chevron_right, size: 20),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _outlinedBorder(context),
      child: ListTile(
        title: title,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: content),
        onTap: onTap,
      ),
    );
  }
}

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
          _ImportExport(),
        ],
      ),
    );
  }
}

class _ThemeChanger extends ConsumerWidget {
  const _ThemeChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelOf = {
      backend.Theme.system: context.t.system,
      backend.Theme.light: context.t.light,
      backend.Theme.dark: context.t.dark,
    };
    final settings = ref.watch(appSettingsProvider);
    return _SettingsCard(
      title: Text('🎨 ${context.t.theme}'),
      value: labelOf[settings.theme]!,
      onTap: () async {
        final v = await _showSettingDialog(
          context,
          emoji: '🎨',
          title: context.t.theme,
          current: settings.theme,
          items: backend.Theme.values.map((e) => (e, labelOf[e]!)).toList(),
        );
        if (v != null && context.mounted) {
          ref.read(appSettingsProvider.notifier).setTheme(v);
        }
      },
    );
  }
}

class _LanguageChanger extends ConsumerWidget {
  const _LanguageChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelOf = {
      backend.Language.en: context.t.en,
      backend.Language.ru: context.t.ru,
    };
    final settings = ref.watch(appSettingsProvider);
    return _SettingsCard(
      title: Text('🌐 ${context.t.language}'),
      value: labelOf[settings.language]!,
      onTap: () async {
        final v = await _showSettingDialog(
          context,
          emoji: '🌐',
          title: context.t.language,
          current: settings.language,
          items: backend.Language.values.map((e) => (e, labelOf[e]!)).toList(),
        );
        if (v != null && context.mounted) {
          ref.read(appSettingsProvider.notifier).setLanguage(v);
        }
      },
    );
  }
}

class _CurrencyChanger extends ConsumerWidget {
  const _CurrencyChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelOf = {
      backend.Currency.usd: context.t.usd,
      backend.Currency.rub: context.t.rub,
      backend.Currency.eur: context.t.eur,
    };
    final settings = ref.watch(appSettingsProvider);
    return _SettingsCard(
      title: Text('💵 ${context.t.currency}'),
      value: labelOf[settings.currency]!,
      onTap: () async {
        final v = await _showSettingDialog(
          context,
          emoji: '💵',
          title: context.t.currency,
          current: settings.currency,
          items: backend.Currency.values.map((e) => (e, labelOf[e]!)).toList(),
        );
        if (v != null && context.mounted) {
          ref.read(appSettingsProvider.notifier).setCurrency(v);
        }
      },
    );
  }
}

class _MileageChanger extends ConsumerWidget {
  const _MileageChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelOf = {
      backend.DistanceUnit.km: context.t.km,
      backend.DistanceUnit.mi: context.t.mi,
    };
    final settings = ref.watch(appSettingsProvider);
    return _SettingsCard(
      title: Text('📏 ${context.t.mileage}'),
      value: labelOf[settings.distanceUnit]!,
      onTap: () async {
        final v = await _showSettingDialog(
          context,
          emoji: '📏',
          title: context.t.mileage,
          current: settings.distanceUnit,
          items: backend.DistanceUnit.values
              .map((e) => (e, labelOf[e]!))
              .toList(),
        );
        if (v != null && context.mounted) {
          ref.read(appSettingsProvider.notifier).setDistanceUnit(v);
        }
      },
    );
  }
}

class _ImportExport extends ConsumerWidget {
  const _ImportExport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final border = _outlinedBorder(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: helpers.EmojiCard(
              emoji: '📂',
              label: context.t.import,
              onTap: () => importCsv(context, ref),
              border: border,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: helpers.EmojiCard(
              emoji: '💾',
              label: context.t.export,
              onTap: () => exportCsv(context, ref),
              border: border,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
