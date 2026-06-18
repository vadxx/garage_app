// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/backend.dart' as backend;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/pages/helpers.dart' as helpers;
import 'package:garage_app/providers/providers.dart';
import '../app_router.dart';

class StatsGroup extends ConsumerWidget {
  const StatsGroup({super.key, required this.carId, required this.carMileage});
  final int carId;
  final int carMileage;

  Widget _topCatTile(
    BuildContext context,
    String topCatValue, {
    VoidCallback? onTap,
  }) {
    var label = Text(
      context.t.topCategory,
      style: helpers.outlinedTextStyle(context),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
    var value = Text(
      topCatValue,
      style: const TextStyle(fontWeight: FontWeight.w600),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
    return GestureDetector(
      onTap: onTap,
      child: helpers.outlinedTile(
        context,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [label, value],
              ),
            ),
            helpers.iconClickable(context),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _spentTile(
    BuildContext context,
    stats,
    backend.AppSettings settings, {
    VoidCallback? onTap,
  }) {
    var label = Text(
      context.t.spent,
      style: helpers.outlinedTextStyle(context),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
    var value = helpers.costText(
      context,
      value: stats.totalSpent,
      currency: settings.currency,
    );
    return GestureDetector(
      onTap: onTap,
      child: helpers.outlinedTile(
        context,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [label, value],
              ),
            ),
            helpers.iconClickable(context),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
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

      final oilHealthTile = GestureDetector(
        onTap: () => _showOilHistoryBottomSheet(context, ref),
        child: helpers.outlinedTile(
          context,
          _OilHealth(
            stats: stats,
            carMileage: carMileage,
            unit: unit,
            oilIntervalKm: settings.oilIntervalKm,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );

      final topCatTile = _topCatTile(
        context,
        topCatValue,
        onTap: () => _showCategoryRatingsBottomSheet(context, ref, stats),
      );
      final spentTile = _spentTile(
        context,
        stats,
        settings,
        onTap: () => _showMonthlySpendingBottomSheet(context, ref, stats),
      );

      return Column(
        children: [
          if (noOilData) const _NoOilDataNotification(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                oilHealthTile,
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: topCatTile),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: spentTile),
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

  void _showOilHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.read(carWorksProvider(carId));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => worksAsync.when(
        data: (works) {
          final oilWorks =
              works
                  .where((w) => w.category == backend.Category.oil.index)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

          return _StatsBottomSheet(
            title: context.t.catOil,
            emoji: '🛢️',
            count: oilWorks.length,
            child: oilWorks.isEmpty
                ? _emptyState(context, context.t.noOilChangeRecords)
                : ListView.builder(
                    itemCount: oilWorks.length,
                    itemBuilder: (context, index) =>
                        _oilWorkItem(context, ref, oilWorks[index]),
                  ),
          );
        },
        loading: () => _loadingState(context, '🛢️', context.t.catOil),
        error: (e, _) => _errorState(e, '🛢️', context.t.catOil),
      ),
    );
  }

  Widget _oilWorkItem(
    BuildContext context,
    WidgetRef ref,
    backend.CarWork work,
  ) {
    final date = DateTime.fromMillisecondsSinceEpoch(work.date * 1000);
    final dateStr = context.formatCompactDate(date);
    final currency = ref.read(appSettingsProvider).currency;
    return ListTile(
      leading: const Text('🛢️', style: TextStyle(fontSize: 24)),
      title: Text(
        work.description.isEmpty ? context.t.catOil : work.description,
      ),
      subtitle: Text(dateStr),
      trailing: helpers.costText(context, value: work.cost, currency: currency),
      onTap: () {
        Navigator.pop(context);
        goToEditCarWork(context, carId, work.id);
      },
    );
  }

  void _showMonthlySpendingBottomSheet(
    BuildContext context,
    WidgetRef ref,
    stats,
  ) {
    final worksAsync = ref.read(carWorksProvider(carId));
    final settings = ref.read(appSettingsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => worksAsync.when(
        data: (works) {
          final monthlySpending = <String, int>{};
          final monthlyWorksCount = <String, int>{};
          for (final work in works) {
            final date = DateTime.fromMillisecondsSinceEpoch(work.date * 1000);
            final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
            monthlySpending[key] = (monthlySpending[key] ?? 0) + work.cost;
            monthlyWorksCount[key] = (monthlyWorksCount[key] ?? 0) + 1;
          }
          final sortedMonths = monthlySpending.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          return _StatsBottomSheet(
            title: context.t.monthlySpendings,
            emoji: '📅',
            count: sortedMonths.length,
            child: sortedMonths.isEmpty
                ? _emptyState(context, context.t.noSpendingRecords)
                : ListView.builder(
                    itemCount: sortedMonths.length,
                    itemBuilder: (context, index) => _monthItem(
                      context,
                      settings,
                      monthlyWorksCount,
                      sortedMonths[index],
                    ),
                  ),
          );
        },
        loading: () => _loadingState(context, '📅', context.t.monthlySpendings),
        error: (e, _) => _errorState(e, '📅', context.t.monthlySpendings),
      ),
    );
  }

  Widget _monthItem(
    BuildContext context,
    backend.AppSettings settings,
    Map<String, int> monthlyWorksCount,
    MapEntry<String, int> entry,
  ) {
    final parts = entry.key.split('-');
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);
    final date = DateTime(year, month);
    final monthName = '${helpers.monthName(context, date.month)} $year';
    final worksCount = monthlyWorksCount[entry.key] ?? 0;
    final now = DateTime.now();
    final isCurrentMonth = date.year == now.year && date.month == now.month;
    return ListTile(
      title: Text(
        isCurrentMonth ? '$monthName (${context.t.current})' : monthName,
      ),
      subtitle: Text('$worksCount ${context.t.works}'),
      trailing: helpers.costText(
        context,
        value: entry.value,
        currency: settings.currency,
      ),
    );
  }

  void _showCategoryRatingsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    stats,
  ) {
    final worksAsync = ref.read(carWorksProvider(carId));
    final settings = ref.read(appSettingsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => worksAsync.when(
        data: (works) {
          final categorySpending = <int, int>{};
          for (final work in works) {
            categorySpending[work.category] =
                (categorySpending[work.category] ?? 0) + work.cost;
          }
          final sortedCategories = categorySpending.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final totalSpent = sortedCategories.fold(
            0,
            (sum, entry) => sum + entry.value,
          );
          return _StatsBottomSheet(
            title: context.t.categoryRatings,
            emoji: '📊',
            count: sortedCategories.length,
            child: sortedCategories.isEmpty
                ? _emptyState(context, context.t.noCategoryRecords)
                : ListView.builder(
                    itemCount: sortedCategories.length,
                    itemBuilder: (context, index) => _categoryItem(
                      context,
                      settings,
                      totalSpent,
                      sortedCategories[index],
                    ),
                  ),
          );
        },
        loading: () => _loadingState(context, '📊', context.t.categoryRatings),
        error: (e, _) => _errorState(e, '📊', context.t.categoryRatings),
      ),
    );
  }

  Widget _categoryItem(
    BuildContext context,
    backend.AppSettings settings,
    int totalSpent,
    MapEntry<int, int> entry,
  ) {
    final category = backend.Category.values[entry.key];
    final percentage = totalSpent > 0
        ? (entry.value / totalSpent * 100).round()
        : 0;
    return ListTile(
      leading: Text(
        helpers.categoryEmoji(category),
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(helpers.categoryLabel(category, context)),
      subtitle: LinearProgressIndicator(
        value: percentage / 100,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          helpers.costText(
            context,
            value: entry.value,
            currency: settings.currency,
          ),
          Text('$percentage%', style: helpers.outlinedTextStyle(context)),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  Widget _loadingState(BuildContext context, String emoji, String title) {
    return _StatsBottomSheet(
      title: title,
      emoji: emoji,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorState(Object e, String emoji, String title) {
    return _StatsBottomSheet(
      title: title,
      emoji: emoji,
      child: Center(child: Text('Error: $e')),
    );
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
          style: TextStyle(fontSize: 13, color: healthColor),
        ),
        const SizedBox(width: 4),
        helpers.iconClickable(context),
      ],
    );
  }
}

class _StatsBottomSheet extends StatelessWidget {
  const _StatsBottomSheet({
    required this.title,
    required this.emoji,
    this.count,
    required this.child,
  });

  final String title;
  final String emoji;
  final int? count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      count != null ? '$title ($count)' : title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, _) {
        final content = [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          label,
        ];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: content),
            ),
            const Divider(height: 1),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
