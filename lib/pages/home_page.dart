// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/backend.dart' hide Theme;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

import '../providers/providers.dart';

import 'helpers.dart' as helpers;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.t.appTitle;
    final settingsButton = TextButton.icon(
      onPressed: () => goToSettings(context),
      label: Text('⚙️', style: helpers.bigTextSize),
    );
    final addCarButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(18),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => goToAddCar(context),
      icon: Text('➕', style: helpers.bigTextSize),
      label: Text(context.t.addCar, style: helpers.bigTextSize),
    );
    return Scaffold(
      appBar: AppBar(
        leading: Center(child: Text('🚗', style: helpers.bigTextSize)),
        title: Text(title),
        titleSpacing: 0, // Drop the gap btw the leading and title
        actions: [settingsButton],
      ),
      body: const _CarsList(),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: addCarButton,
      ),
    );
  }
}

class _CarsList extends ConsumerWidget {
  const _CarsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    final border = BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    );
    const margin = EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (_, i) {
        return Container(
          margin: margin,
          decoration: border,
          child: _CarTile(car: cars[i]),
        );
      },
    );
  }
}

class _CarTile extends ConsumerWidget {
  final Car car;
  const _CarTile({required this.car});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carStats = ref.watch(carStatsProvider(car.id));
    final spent = carStats.when(
      data: (s) => '\$${s.totalSpent}',
      loading: () => '\$0',
      error: (_, _) => '\$0',
    );

    void onTap() => goToCarDetail(context, car.id);
    final color = helpers.CircleColor(
      color: helpers.carColorPalette[car.color].$2,
      selected: false,
      width: 16,
      height: 16,
    );
    final carPriceTitle = Text(
      '\$${car.price}',
      style: TextStyle(
        fontSize: 20,
        color: Colors.green.shade600,
        fontWeight: FontWeight.bold,
      ),
    );
    final title = Row(
      children: [
        color,
        SizedBox(width: 8),
        Text(
          '${car.make} ${car.model}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Spacer(),
        carPriceTitle,
      ],
    );
    final subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: plate in border
        _carPlate(car.plate),
        Row(
          children: [
            helpers.subColumn(context.t.year, '${car.year}'),
            Spacer(),
            helpers.subColumn(context.t.mileage, '${car.mileage} km'),
            Spacer(),
            helpers.subColumn(context.t.spent, spent, valueColor: Colors.red),
          ],
        ),
      ],
    );
    return ListTile(title: title, subtitle: subtitle, onTap: onTap);
  }

  Container _carPlate(String value) {
    final border = BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(4),
    );
    return Container(
      decoration: border,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(car.plate),
    );
  }
}
