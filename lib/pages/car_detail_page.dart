// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_app/i18n/i18n.dart';

import '../app_router.dart';
// import '../i18n/i18n.dart';

import '../providers/providers.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => goToAddCarWork(context, car.id),
      icon: Text('➕', style: helpers.bigTextSize),
      label: Text(context.t.addWork, style: helpers.bigTextSize),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToHome(context)),
        title: Row(
          children: [
            helpers.CircleColor(
              color: helpers.carColorPalette[car.color].$2,
              selected: false,
              width: 16,
              height: 16,
            ),
            SizedBox(width: 8),
            Text(car.model),
            SizedBox(width: 8),
            Text(
              '${car.year}',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [editButton],
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: addWorkButton,
      ),
    );
  }
}
