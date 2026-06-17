// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';
import 'package:backend/backend.dart' show distanceUnitLabel, currencySymbol;
import 'package:backend/backend.dart' as backend hide Theme;
import '../providers/providers.dart';

import 'helpers.dart' as helpers;

class AddEditCarWorkPage extends ConsumerWidget {
  final int carId;
  final int? workId;
  const AddEditCarWorkPage({super.key, required this.carId, this.workId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEdit = workId != null;
    final arg = CarWorkFormArg(carId, workId);
    final form = ref.watch(carWorkFormProvider(arg));
    final notifier = ref.read(carWorkFormProvider(arg).notifier);

    final String modeTitle = isEdit ? context.t.editWork : context.t.addWork;

    final category = _CategorySelector(
      selected: form.category,
      onChanged: notifier.setCategory,
    );
    final date = _DatePicker(date: form.date, onChanged: notifier.setDate);

    final settings = ref.watch(appSettingsProvider);
    final distanceUnit = settings.distanceUnit;
    final currencySym = currencySymbol(settings.currency);
    final mileage = helpers.Field(
      label: '${context.t.mileage} (${distanceUnitLabel(distanceUnit)})',
      controller: notifier.mileageController,
      error: form.mileageError,
      onChanged: notifier.setMileage,
      keyboardType: TextInputType.number,
    );
    final cost = helpers.Field(
      label: '${context.t.price} ($currencySym)',
      controller: notifier.costController,
      error: form.costError,
      onChanged: notifier.setCost,
      keyboardType: TextInputType.number,
    );
    final formBody = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        category,
        SizedBox(height: 12),
        date,
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: mileage),
            SizedBox(width: 12),
            Expanded(child: cost),
          ],
        ),
        helpers.Field(
          label: context.t.description,
          controller: notifier.descriptionController,
          error: form.descriptionError,
          onChanged: notifier.setDescription,
        ),
      ],
    );
    Future<void> onDeleteWork() async {
      final confirmed = await _showDeleteWorkDialog(context) ?? false;
      if (confirmed && context.mounted) {
        notifier.deleteWork(context);
      }
    }

    final deleteWork = SizedBox(
      child: IconButton(
        onPressed: onDeleteWork,
        icon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: helpers.deleteIcon,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => goToCarDetail(context, carId)),
        title: Text(modeTitle),
        titleSpacing: 0,
        actions: [if (isEdit) deleteWork],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: formBody,
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(18),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => notifier.save(context),
          icon: Text('💾', style: helpers.bigTextSize),
          label: Text(context.t.saveChanges, style: helpers.bigTextSize),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteWorkDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (ctx) => helpers.styledDialog(
      title: Row(
        children: [
          helpers.deleteIcon,
          SizedBox(width: 8),
          Text(
            context.t.deleteWork,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Text(context.t.areYouSure, style: const TextStyle(fontSize: 16)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        helpers.cancelButton(
          onPressed: () => Navigator.pop(ctx, false),
          label: context.t.cancel,
        ),
        const SizedBox(width: 12),
        helpers.deleteButton(
          context,
          onPressed: () => Navigator.pop(ctx, true),
          label: context.t.delete,
        ),
      ],
    ),
  );
}

class _CategorySelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const itemMaxHeight = 64.0;
    const itemGap = 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.t.category,
          style: TextStyle(fontSize: 12, letterSpacing: 0.6),
        ),
        SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth - itemGap * 2) / 3;
            final aspectRatio = cellWidth / itemMaxHeight;
            return GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: itemGap,
              crossAxisSpacing: itemGap,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: aspectRatio,
              children: List.generate(backend.Category.values.length, (i) {
                return _CategoryButton(
                  index: i,
                  cat: backend.Category.values[i],
                  isSelected: selected == i,
                  onChanged: onChanged,
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.index,
    required this.cat,
    required this.isSelected,
    required this.onChanged,
  });

  final int index;
  final backend.Category cat;
  final bool isSelected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = BoxDecoration(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withAlpha(15)
          : Theme.of(context).colorScheme.secondary.withAlpha(15),
      border: Border.fromBorderSide(
        BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      borderRadius: BorderRadius.circular(12),
    );
    return helpers.EmojiCard(
      emoji: helpers.categoryEmoji(cat),
      label: helpers.categoryLabel(cat, context),
      onTap: () => onChanged(index),
      border: border,
    );
  }
}

class _DatePicker extends StatelessWidget {
  final int date;
  final ValueChanged<int> onChanged;

  const _DatePicker({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dt = backend.epochSecondsToDateTime(date);
    final dateStr = context.formatCompactDate(dt);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dt,
          firstDate: backend.datePickerMinDate(),
          lastDate: backend.datePickerMaxDate(),
        );
        if (picked != null) {
          onChanged(backend.dateTimeToEpochSeconds(picked));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.t.date,
          border: OutlineInputBorder(),
        ),
        child: Text(dateStr),
      ),
    );
  }
}
