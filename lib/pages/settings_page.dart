// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

import '../providers/providers.dart';
import '../urls.dart';
import 'package:backend/backend.dart' as backend;
import 'donate_section.dart';
import 'helpers.dart' as helpers;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = context.t.settings;
    final supportButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(18),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => showSupportUsBottomSheet(context, ref),
      icon: Text('🥰', style: helpers.bigTextSize),
      label: Text(context.t.supportUs, style: helpers.bigTextSize),
    );
    return helpers.CenteredMaxWidth(
      child: Scaffold(
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
            _OilIntervalChanger(),
            _ImportExport(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: supportButton,
        ),
      ),
    );
  }
}

/// Shows a bottom sheet with support us content.
void showSupportUsBottomSheet(BuildContext context, WidgetRef ref) {
  final label = Text(
    context.t.supportUs,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
  final rateApp = Container(
    decoration: helpers.outlinedBorder(context),
    child: ListTile(
      leading: const SizedBox(
        width: 24,
        height: 24,
        child: Center(child: Text('💖', style: TextStyle(fontSize: 20))),
      ),
      title: Text(context.t.rateTheApp),
      trailing: helpers.iconClickable(context),
      onTap: () => launchUrl(
        Uri.parse(googlePlayUrl),
        mode: LaunchMode.externalApplication,
      ),
    ),
  );
  final github = Container(
    decoration: helpers.outlinedBorder(context),
    child: ListTile(
      leading: helpers.githubIcon(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: const Text('GitHub'),
      trailing: helpers.iconClickable(context),
      onTap: () =>
          launchUrl(Uri.parse(githubUrl), mode: LaunchMode.externalApplication),
    ),
  );
  final email = Container(
    decoration: helpers.outlinedBorder(context),
    child: ListTile(
      leading: const Icon(Icons.mail_outline, size: 24),
      title: Text(context.t.contactUs),
      trailing: helpers.iconClickable(context),
      onTap: () => launchUrl(
        Uri.parse(contactUsUri),
        mode: LaunchMode.externalApplication,
      ),
    ),
  );
  helpers.showAppBottomSheet(context, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('🥰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              label,
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DonateSection(),
              rateApp,
              const SizedBox(height: 12),
              github,
              const SizedBox(height: 8),
              email,
            ],
          ),
        ),
      ],
    );
  });
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
      backend.Language.de: context.t.de,
      backend.Language.es: context.t.es,
      backend.Language.fr: context.t.fr,
      backend.Language.pt: context.t.pt,
      backend.Language.ko: context.t.ko,
      backend.Language.ja: context.t.ja,
      backend.Language.id: context.t.id,
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
    String label(backend.Currency currency) {
      final code = switch (currency) {
        backend.Currency.usd => context.t.usd,
        backend.Currency.rub => context.t.rub,
        backend.Currency.eur => context.t.eur,
        backend.Currency.gbp => context.t.gbp,
        backend.Currency.krw => context.t.krw,
        backend.Currency.jpy => context.t.jpy,
        backend.Currency.idr => context.t.idr,
        backend.Currency.brl => context.t.brl,
        backend.Currency.mxn => context.t.mxn,
      };
      return '$code (${backend.currencySymbol(currency)})';
    }

    final labelOf = {
      for (final currency in backend.Currency.values) currency: label(currency),
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
      title: Text('📏 ${context.t.distanceUnit}'),
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

class _OilIntervalChanger extends ConsumerWidget {
  const _OilIntervalChanger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final unit = settings.distanceUnit;
    final valueInUnit = backend.distanceToUnit(settings.oilIntervalKm, unit);
    final unitLabel = backend.distanceUnitLabel(unit);
    final controller = TextEditingController(text: valueInUnit.toString());
    final field = TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$unitLabel (${context.t.mileage})',
        border: const OutlineInputBorder(),
      ),
    );
    return _SettingsCard(
      title: Text('🛢️ ${context.t.oilIntervalKm}'),
      value: '$valueInUnit $unitLabel',
      onTap: () async {
        final result = await showDialog<int>(
          context: context,
          builder: (ctx) => helpers.styledDialog(
            title: Text(
              '🛢️ ${context.t.oilIntervalKm}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [field]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.t.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final v = int.tryParse(controller.text);
                  Navigator.pop(ctx, v);
                },
                child: Text(context.t.save),
              ),
            ],
          ),
        );
        if (result != null && result > 0 && context.mounted) {
          final inKm = backend.unitToKm(result, unit);
          ref.read(appSettingsProvider.notifier).setOilIntervalKm(inKm);
        }
      },
    );
  }
}

class _ImportExport extends ConsumerWidget {
  const _ImportExport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final border = helpers.outlinedBorder(context);
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
      helpers.iconClickable(context),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: helpers.outlinedBorder(context),
      child: ListTile(
        title: title,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: content),
        onTap: onTap,
      ),
    );
  }
}

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
      content: SingleChildScrollView(
        child: Column(
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
    ),
  );
}
