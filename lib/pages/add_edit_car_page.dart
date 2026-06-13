// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:backend/backend.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';
import '../providers/providers.dart';

const _bigTextSize = TextStyle(fontSize: 20);

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(carFormProvider.notifier).loadCar(car);
      });
    }

    final String modeTitle = isEdit ? context.t.editCar : context.t.addCar;
    final saveButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => notifier.save(context, carId: carId),
      icon: Text('💾', style: _bigTextSize),
      label: Text(context.t.saveChanges, style: _bigTextSize),
    );

    final formFields = [
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

    final deleteCar = SizedBox(
      child: IconButton(
        onPressed: () async {
          final confirmed = await showDeleteCarDialog(context) ?? false;
          if (confirmed && context.mounted) {
            ref.read(carsProvider.notifier).deleteCar(carId!);
            goToHome(context);
          }
        },
        icon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToHome(context)),
        title: Text(modeTitle),
        titleSpacing: 0,
        actions: [if (isEdit) deleteCar],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...formFields, ...colorsGroup],
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: 64,
        child: Padding(padding: const EdgeInsets.all(4.0), child: saveButton),
      ),
    );
  }

  Future<bool?> showDeleteCarDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.t.deleteCar),
      content: Text(context.t.areYouSure),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.t.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.t.delete),
        ),
      ],
    ),
  );
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
