// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_app/i18n/i18n.dart';

import '../app_router.dart';
// import '../i18n/i18n.dart';

import '../providers/providers.dart';

import 'helpers.dart' as helpers;
import 'package:backend/backend.dart' as backend;

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
        child: Column(children: [_StatsTile(carId: car.id)]),
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
  const _StatsTile({required this.carId});
  final int carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carStats = ref.watch(carStatsProvider(carId));
    Widget onStatsData(stats) {
      final statsRow = Row(
        children: [
          Spacer(),
          helpers.subColumn(
            context.t.lastOilChange,
            '${stats.lastOilChangeKm} km',
          ),
          Spacer(),
          helpers.subColumn(
            context.t.spent,
            '\$${stats.totalSpent}',
            valueColor: Colors.red,
          ),
          Spacer(),
        ],
      );
      return Padding(padding: EdgeInsets.all(16), child: statsRow);
    }

    return carStats.when(
      data: onStatsData,
      loading: () => SizedBox.shrink(),
      error: (e, _) => Center(child: Text('Error loading stats: $e')),
    );
  }
}
