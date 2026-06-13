// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:backend/backend.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';
import '../providers/providers.dart';

const _bigTextSize = TextStyle(fontSize: 24);

const _colorPalette = [
  (CarColor.white, Colors.white),
  (CarColor.black, Colors.black),
  (CarColor.silver, Colors.grey),
  (CarColor.blue, Colors.blue),
  (CarColor.red, Colors.red),
  (CarColor.green, Colors.green),
];

class AddEditCarPage extends ConsumerWidget {
  final int? carId;
  const AddEditCarPage({super.key, this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEdit = carId != null;
    final form = ref.watch(carFormProvider);
    final notifier = ref.read(carFormProvider.notifier);

    // Load car data on first build for edit mode
    if (isEdit && form.make.isEmpty) {
      final cars = ref.watch(carsProvider);
      final car = cars.firstWhere((c) => c.id == carId);
      ref.read(carFormProvider.notifier).loadCar(car);
    }

    final String modeTitle = isEdit ? context.t.editCar : context.t.addCar;
    final saveButton = TextButton.icon(
      onPressed: () => notifier.save(context, carId: carId),
      label: Text('💾', style: _bigTextSize),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToHome(context)),
        title: Text(modeTitle),
        titleSpacing: 0,
        actions: [saveButton],
      ),
      body: const _FieldsList(),
    );
  }
}

class _FieldsList extends ConsumerWidget {
  const _FieldsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(carFormProvider);
    final notifier = ref.read(carFormProvider.notifier);
    final fields = [
      _Field(
        label: context.t.make,
        controller: notifier.makeController,
        error: form.makeError,
        onChanged: notifier.setMake,
      ),
      _Field(
        label: context.t.model,
        controller: notifier.modelController,
        error: form.modelError,
        onChanged: notifier.setModel,
      ),
      _Field(
        label: context.t.year,
        controller: notifier.yearController,
        error: form.yearError,
        keyboardType: TextInputType.number,
        onChanged: notifier.setYear,
      ),
      _Field(
        label: context.t.plate,
        controller: notifier.plateController,
        onChanged: notifier.setPlate,
      ),
      _Field(
        label: context.t.price,
        controller: notifier.priceController,
        keyboardType: TextInputType.number,
        onChanged: notifier.setPrice,
      ),
      _Field(
        label: context.t.mileage,
        controller: notifier.mileageController,
        keyboardType: TextInputType.number,
        onChanged: notifier.setMileage,
      ),
    ];
    final colorsGroup = [
      const SizedBox(height: 16),
      Text(context.t.color),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        children: _colorPalette.map((c) {
          final (_, color) = c;
          final selected = form.colorIndex == c.$1.index;
          return GestureDetector(
            onTap: () => notifier.setColor(c.$1.index),
            child: _CircleColor(color: color, selected: selected),
          );
        }).toList(),
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...fields, ...colorsGroup],
      ),
    );
  }
}

class _CircleColor extends StatelessWidget {
  const _CircleColor({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade400,
          width: selected ? 3 : 1,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? error;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const _Field({
    required this.label,
    this.error,
    this.keyboardType,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}
