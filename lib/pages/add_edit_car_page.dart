// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';
import '../providers/providers.dart';

import 'helpers.dart' as helpers;

class AddEditCarPage extends ConsumerWidget {
  final int? carId;
  const AddEditCarPage({super.key, this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEdit = carId != null;
    final form = ref.watch(carFormProvider(carId));
    final notifier = ref.read(carFormProvider(carId).notifier);

    final String modeTitle = isEdit ? context.t.editCar : context.t.addCar;
    final saveButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => notifier.save(context),
      icon: Text('💾', style: helpers.bigTextSize),
      label: Text(context.t.saveChanges, style: helpers.bigTextSize),
    );

    final formFields = [
      helpers.Field(
        label: context.t.make,
        controller: notifier.makeController,
        error: form.makeError,
        onChanged: notifier.setMake,
      ),
      helpers.Field(
        label: context.t.model,
        controller: notifier.modelController,
        error: form.modelError,
        onChanged: notifier.setModel,
      ),
      helpers.Field(
        label: context.t.year,
        controller: notifier.yearController,
        error: form.yearError,
        onChanged: notifier.setYear,
        keyboardType: TextInputType.number,
      ),
      helpers.Field(
        label: context.t.plate,
        controller: notifier.plateController,
        error: form.plateError,
        onChanged: notifier.setPlate,
      ),
      helpers.Field(
        label: context.t.price,
        controller: notifier.priceController,
        error: form.priceError,
        onChanged: notifier.setPrice,
        keyboardType: TextInputType.number,
      ),
      helpers.Field(
        label: context.t.mileage,
        controller: notifier.mileageController,
        error: form.mileageError,
        onChanged: notifier.setMileage,
        keyboardType: TextInputType.number,
      ),
    ];
    final colorsGroup = [
      Text(context.t.color),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: helpers.carColorPalette.map((c) {
          final (_, color) = c;
          final selected = form.colorIndex == c.$1.index;
          return GestureDetector(
            onTap: () => notifier.setColor(c.$1.index),
            child: helpers.CircleColor(color: color, selected: selected),
          );
        }).toList(),
      ),
    ];

    void onDeleteCar() => () async {
      final confirmed = await _showDeleteCarDialog(context) ?? false;
      if (confirmed && context.mounted) {
        ref.read(carsProvider.notifier).deleteCar(carId!);
        goToHome(context);
      }
    };
    final deleteCar = SizedBox(
      child: IconButton(
        onPressed: onDeleteCar,
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
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...formFields, ...colorsGroup],
        ),
      ),
      bottomNavigationBar: SizedBox(width: double.infinity, child: saveButton),
    );
  }

  Future<bool?> _showDeleteCarDialog(BuildContext context) => showDialog<bool>(
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
