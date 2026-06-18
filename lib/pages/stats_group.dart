// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/backend.dart' as backend;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/pages/helpers.dart' as helpers;
import 'package:garage_app/providers/providers.dart';

class StatsGroup extends ConsumerWidget {
  const StatsGroup({super.key, required this.carId, required this.carMileage});
  final int carId;
  final int carMileage;

  Widget _topCatTile(BuildContext context, String topCatValue) {
    var label = Text(
      context.t.topCategory,
      style: _outlinedText(context),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
    var value = Text(
      topCatValue,
      style: const TextStyle(fontWeight: FontWeight.w600),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
    return helpers.outlinedTile(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [label, value],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _spentTile(BuildContext context, stats, backend.AppSettings settings) {
    var label = Text(
      context.t.spent,
      style: _outlinedText(context),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
    var value = Text(
      backend.formatCurrency(stats.totalSpent, settings.currency),
      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      overflow: TextOverflow.ellipsis,
    );
    return helpers.outlinedTile(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [label, value],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final unit = settings.distanceUnit;
    final carStats = ref.watch(carStatsProvider(carId));

    Widget onStatsData(stats) {
      final noOilData = stats.lastOilChangeKm == -1;

      final topCat = stats.topCategory >= 0
          ? backend.Category.values[stats.topCategory]
          : null;
      final topCatValue = topCat != null
          ? '${helpers.categoryEmoji(topCat)} ${helpers.categoryLabel(topCat, context)}'
          : '—';
      final oilHealth = _OilHealth(
        stats: stats,
        carMileage: carMileage,
        unit: unit,
        oilIntervalKm: settings.oilIntervalKm,
      );
      return Column(
        children: [
          if (noOilData) const _NoOilDataNotification(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                helpers.outlinedTile(
                  context,
                  oilHealth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _topCatTile(context, topCatValue)),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _spentTile(context, stats, settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return carStats.when(
      data: onStatsData,
      loading: () => SizedBox.shrink(),
      error: (e, _) =>
          Center(child: Text('${context.t.errorLoadingStats}: $e')),
    );
  }

  TextStyle _outlinedText(BuildContext context) {
    final outlineTextStyle = TextStyle(
      fontSize: 12,
      letterSpacing: 0.6,
      color: Theme.of(context).colorScheme.outline,
    );
    return outlineTextStyle;
  }
}

class _NoOilDataNotification extends StatelessWidget {
  const _NoOilDataNotification();

  @override
  Widget build(BuildContext context) {
    final iconWarn = Icon(
      Icons.warning_amber_rounded,
      size: 18,
      color: Theme.of(context).colorScheme.onErrorContainer,
    );
    final noOilDataText = Text(
      context.t.oilChangeDataNotProvided,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.errorContainer.withAlpha(120),
      child: Row(
        children: [
          iconWarn,
          SizedBox(width: 8),
          Expanded(child: noOilDataText),
        ],
      ),
    );
  }
}

class _OilHealth extends StatelessWidget {
  const _OilHealth({
    required this.stats,
    required this.carMileage,
    required this.unit,
    required this.oilIntervalKm,
  });

  final backend.CarStats stats;
  final int carMileage;
  final backend.DistanceUnit unit;
  final int oilIntervalKm;

  Color _healthColor(int pct) => pct >= 60
      ? Colors.green
      : pct >= 30
      ? Colors.orange
      : Colors.red;

  @override
  Widget build(BuildContext context) {
    final oil = backend.oilHealth(stats, carMileage, intervalKm: oilIntervalKm);
    final healthColor = _healthColor(oil.healthPercent);
    final healthCircle = Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
    );
    final healthValue = Text(
      '${oil.healthPercent}%',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: healthColor,
      ),
    );
    return Row(
      children: [
        const Text('🛢️', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text('${context.t.oilLife}:', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [healthCircle, const SizedBox(width: 4), healthValue],
        ),
        const Spacer(),
        Text(
          backend.formatDistance(oil.kmSince, unit),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
