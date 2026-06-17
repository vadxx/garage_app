// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';

import 'cars_provider.dart';
import 'car_stats_provider.dart';
import 'car_works_provider.dart';
import 'repositories_provider.dart';
import 'app_settings_provider.dart';
import '../app_router.dart';

class CarWorkFormState {
  final int category;
  final int date;
  final bool isLoaded;
  final String? mileageError, costError, descriptionError;

  const CarWorkFormState({
    this.category = 0,
    this.date = 0,
    this.isLoaded = false,
    this.mileageError,
    this.costError,
    this.descriptionError,
  });

  CarWorkFormState copyWith({
    int? category,
    int? date,
    bool? isLoaded,
    String? Function()? mileageError,
    String? Function()? costError,
    String? Function()? descriptionError,
  }) => CarWorkFormState(
    category: category ?? this.category,
    date: date ?? this.date,
    isLoaded: isLoaded ?? this.isLoaded,
    mileageError: mileageError != null ? mileageError() : this.mileageError,
    costError: costError != null ? costError() : this.costError,
    descriptionError: descriptionError != null
        ? descriptionError()
        : this.descriptionError,
  );
}

class CarWorkFormArg {
  final int carId;
  final int? workId;
  const CarWorkFormArg(this.carId, this.workId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarWorkFormArg && carId == other.carId && workId == other.workId;

  @override
  int get hashCode => Object.hash(carId, workId);
}

class CarWorkFormNotifier
    extends AutoDisposeFamilyNotifier<CarWorkFormState, CarWorkFormArg> {
  late final TextEditingController mileageController;
  late final TextEditingController costController;
  late final TextEditingController descriptionController;

  @override
  CarWorkFormState build(CarWorkFormArg arg) {
    mileageController = TextEditingController();
    costController = TextEditingController();
    descriptionController = TextEditingController();
    ref.onDispose(() {
      mileageController.dispose();
      costController.dispose();
      descriptionController.dispose();
    });

    final workId = arg.workId;
    if (workId != null) {
      final repo = ref.read(carWorksRepositoryProvider);
      final works = repo.loadByCarId(arg.carId);
      final work = works.firstWhere((w) => w.id == workId);
      final settings = ref.read(appSettingsProvider);
      mileageController.text = work.mileage.toString();
      costController.text = usdToCurrency(
        work.cost,
        settings.currency,
      ).toString();
      descriptionController.text = work.description;
      return CarWorkFormState(
        category: work.category,
        date: work.date,
        isLoaded: true,
      );
    }
    final cars = ref.read(carsProvider);
    final car = cars.firstWhere((c) => c.id == arg.carId);
    mileageController.text = car.mileage.toString();
    return CarWorkFormState(date: currentEpochSeconds());
  }

  void setCategory(int v) => state = state.copyWith(category: v);
  void setDate(int v) => state = state.copyWith(date: v);

  void setMileage(String v) => state = state.copyWith(mileageError: () => null);
  void setCost(String v) => state = state.copyWith(costError: () => null);
  void setDescription(String v) =>
      state = state.copyWith(descriptionError: () => null);

  bool _hasValue(String v) => v.trim().isNotEmpty;

  bool validate() {
    String? mileageErr, costErr, descErr;

    if (!_hasValue(mileageController.text)) {
      mileageErr = 'required';
    } else {
      final m = int.tryParse(mileageController.text);
      if (m == null || m < 0) mileageErr = 'enterValidMileage';
    }

    if (!_hasValue(costController.text)) {
      costErr = 'required';
    } else {
      final c = int.tryParse(costController.text);
      if (c == null || c <= 0) costErr = 'enterValidCost';
    }

    if (!_hasValue(descriptionController.text)) {
      descErr = 'required';
    }

    state = state.copyWith(
      mileageError: () => mileageErr,
      costError: () => costErr,
      descriptionError: () => descErr,
    );
    return mileageErr == null && costErr == null && descErr == null;
  }

  void deleteWork(BuildContext context) {
    final arg = this.arg;
    final repo = ref.read(carWorksRepositoryProvider);
    repo.delete(arg.workId!);
    final carsRepo = ref.read(carsRepositoryProvider);
    carsRepo.recalculateCarStats(arg.carId);
    ref.invalidate(carWorksProvider(arg.carId));
    ref.invalidate(carStatsProvider(arg.carId));
    goToCarDetail(context, arg.carId);
  }

  void save(BuildContext context) {
    if (!validate()) return;
    final settings = ref.read(appSettingsProvider);
    final arg = this.arg;
    final mileage = int.parse(mileageController.text);
    final work = CarWork(
      id: arg.workId ?? 0,
      carId: arg.carId,
      date: state.date,
      category: state.category,
      mileage: mileage,
      cost: currencyToUsd(int.parse(costController.text), settings.currency),
      description: descriptionController.text.trim(),
    );
    final repo = ref.read(carWorksRepositoryProvider);
    if (arg.workId != null) {
      repo.update(work);
    } else {
      repo.insert(work);
    }
    final carsRepo = ref.read(carsRepositoryProvider);
    carsRepo.recalculateCarStats(arg.carId);
    final cars = ref.read(carsProvider);
    final car = cars.firstWhere((c) => c.id == arg.carId);
    ref.read(carsProvider.notifier).updateCar(car.copyWith(mileage: mileage));
    ref.invalidate(carWorksProvider(arg.carId));
    ref.invalidate(carStatsProvider(arg.carId));
    goToCarDetail(context, arg.carId);
  }
}

final carWorkFormProvider = NotifierProvider.autoDispose
    .family<CarWorkFormNotifier, CarWorkFormState, CarWorkFormArg>(
      CarWorkFormNotifier.new,
    );
