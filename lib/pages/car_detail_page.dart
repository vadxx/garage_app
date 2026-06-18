// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_app/i18n/i18n.dart';

import '../app_router.dart';

import '../providers/providers.dart';
import 'package:backend/backend.dart' show formatDistance, formatCurrency;
import 'package:backend/backend.dart' as backend;

import 'helpers.dart' as helpers;

class CarDetailPage extends ConsumerWidget {
  const CarDetailPage({super.key, required this.carId});

  final int carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    final car = cars.firstWhere((c) => c.id == carId);

    final editButton = TextButton.icon(
      onPressed: () => goToEditCar(context, carId),
      label: Text('✏️', style: helpers.bigTextSize),
    );

    final addWorkButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(18),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => goToAddCarWork(context, car.id),
      icon: Text('➕', style: helpers.bigTextSize),
      label: Text(context.t.addWork, style: helpers.bigTextSize),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToHome(context)),
        title: _AppBarTitle(car: car),
        titleSpacing: 0,
        actions: [editButton],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _StatsTile(carId: car.id, carMileage: car.mileage),
            _WorksList(carId: car.id),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: addWorkButton,
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.car});
  final backend.Car car;

  @override
  Widget build(BuildContext context) {
    final circleColor = helpers.CircleColor(
      color: helpers.carColorPalette[car.color].$2,
      selected: false,
      width: 16,
      height: 16,
    );
    const yearTxtStyle = TextStyle(fontSize: 20, color: Colors.grey);
    return Row(
      children: [
        circleColor,
        SizedBox(width: 8),
        Text(car.model),
        SizedBox(width: 8),
        Text('${car.year}', style: yearTxtStyle),
      ],
    );
  }
}

class _StatsTile extends ConsumerWidget {
  const _StatsTile({required this.carId, required this.carMileage});
  final int carId;
  final int carMileage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final unit = settings.distanceUnit;
    final carStats = ref.watch(carStatsProvider(carId));
    Widget onStatsData(stats) {
      final noOilData = stats.lastOilChangeKm == -1;
      final oilKm = noOilData ? carMileage : stats.lastOilChangeKm;

      final topCatLabel = stats.topCategory >= 0
          ? helpers.categoryLabel(
              backend.Category.values[stats.topCategory],
              context,
            )
          : '—';
      final topCatValue = stats.topCategory >= 0 ? topCatLabel : '—';
      final statsRow = Column(
        children: [
          Row(
            children: [
              helpers.subColumn(context, context.t.topCategory, topCatValue),
              const Spacer(),
              helpers.subColumn(
                context,
                context.t.spent,
                formatCurrency(stats.totalSpent, settings.currency),
                valueColor: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              helpers.subColumn(
                context,
                context.t.lastOilChange,
                formatDistance(oilKm, unit),
              ),
            ],
          ),
        ],
      );
      return Column(
        children: [
          if (noOilData) const _NoOilDataNotification(),
          Padding(padding: EdgeInsets.all(16), child: statsRow),
        ],
      );
    }

    return carStats.when(
      data: onStatsData,
      loading: () => SizedBox.shrink(),
      error: (e, _) => Center(child: Text('Error loading stats: $e')),
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
      'Oil change data not provided. Add an "Oil change" work entry.',
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

class _WorksList extends ConsumerWidget {
  const _WorksList({required this.carId});
  final int carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(carWorksProvider(carId));
    return worksAsync.when(
      data: (works) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '${context.t.serviceHistory} (${works.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (works.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.t.noWorksYet),
            )
          else
            ...works.map((w) => _WorkCard(work: w)),
        ],
      ),
      loading: () => SizedBox.shrink(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _WorkCard extends ConsumerWidget {
  const _WorkCard({required this.work});
  final backend.CarWork work;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final unit = settings.distanceUnit;
    final category = backend.Category.values[work.category];
    final date = DateTime.fromMillisecondsSinceEpoch(work.date * 1000);
    final dateStr = context.formatCompactDate(date);

    final border = BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(8),
    );
    const margin = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

    final title = Row(
      children: [
        Text(
          '${helpers.categoryEmoji(category)} ${helpers.categoryLabel(category, context)}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Spacer(),
        Text(
          formatCurrency(work.cost, settings.currency),
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
      ],
    );
    final subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (work.description.isNotEmpty) Text(work.description),
        Text('$dateStr  •  ${formatDistance(work.mileage, unit)}'),
      ],
    );
    return Container(
      margin: margin,
      decoration: border,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        onTap: () => goToEditCarWork(context, work.carId, work.id),
      ),
    );
  }
}
