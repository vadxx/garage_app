// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';

import 'cars_provider.dart';
import 'app_settings_provider.dart';
import '../app_router.dart';

class CarFormState {
  final int colorIndex;
  final bool isLoaded;
  final String? makeError,
      modelError,
      yearError,
      plateError,
      priceError,
      mileageError;

  const CarFormState({
    this.colorIndex = 0,
    this.isLoaded = false,
    this.makeError,
    this.modelError,
    this.yearError,
    this.plateError,
    this.priceError,
    this.mileageError,
  });

  CarFormState copyWith({
    int? colorIndex,
    bool? isLoaded,
    String? Function()? makeError,
    modelError,
    yearError,
    plateError,
    priceError,
    mileageError,
  }) => CarFormState(
    colorIndex: colorIndex ?? this.colorIndex,
    isLoaded: isLoaded ?? this.isLoaded,
    makeError: makeError != null ? makeError() : this.makeError,
    modelError: modelError != null ? modelError() : this.modelError,
    yearError: yearError != null ? yearError() : this.yearError,
    plateError: plateError != null ? plateError() : this.plateError,
    priceError: priceError != null ? priceError() : this.priceError,
    mileageError: mileageError != null ? mileageError() : this.mileageError,
  );
}

class CarFormNotifier extends AutoDisposeFamilyNotifier<CarFormState, int?> {
  late final TextEditingController makeController;
  late final TextEditingController modelController;
  late final TextEditingController yearController;
  late final TextEditingController plateController;
  late final TextEditingController priceController;
  late final TextEditingController mileageController;

  @override
  CarFormState build(int? carId) {
    makeController = TextEditingController();
    modelController = TextEditingController();
    yearController = TextEditingController();
    plateController = TextEditingController();
    priceController = TextEditingController();
    mileageController = TextEditingController();
    ref.onDispose(() {
      makeController.dispose();
      modelController.dispose();
      yearController.dispose();
      plateController.dispose();
      priceController.dispose();
      mileageController.dispose();
    });

    if (carId != null) {
      final cars = ref.read(carsProvider);
      final car = cars.firstWhere((c) => c.id == carId);
      final settings = ref.read(appSettingsProvider);
      makeController.text = car.make;
      modelController.text = car.model;
      yearController.text = car.year.toString();
      plateController.text = car.plate;
      priceController.text = usdToCurrency(
        car.price,
        settings.currency,
      ).toString();
      mileageController.text = car.mileage.toString();
      return CarFormState(colorIndex: car.color, isLoaded: true);
    }
    return const CarFormState();
  }

  void setMake(String v) => state = state.copyWith(makeError: () => null);
  void setModel(String v) => state = state.copyWith(modelError: () => null);
  void setYear(String v) => state = state.copyWith(yearError: () => null);
  void setPlate(String v) => state = state.copyWith(plateError: () => null);
  void setPrice(String v) => state = state.copyWith(priceError: () => null);
  void setMileage(String v) => state = state.copyWith(mileageError: () => null);
  void setColor(int v) => state = state.copyWith(colorIndex: v);

  bool _hasValue(String v) => v.trim().isNotEmpty;

  bool validate() {
    final now = currentYear;
    String? makeErr, modelErr, yearErr, plateErr, priceErr, mileageErr;

    if (!_hasValue(makeController.text)) makeErr = 'required';
    if (!_hasValue(modelController.text)) modelErr = 'required';
    if (!_hasValue(plateController.text)) plateErr = 'required';

    if (!_hasValue(yearController.text)) {
      yearErr = 'required';
    } else {
      final y = int.tryParse(yearController.text);
      if (y == null) {
        yearErr = 'enterValidYear';
      } else if (y < minYear || y > now) {
        yearErr = 'Year must be $minYear – $now';
      }
    }

    if (!_hasValue(priceController.text)) {
      priceErr = 'required';
    } else {
      final p = int.tryParse(priceController.text);
      if (p == null || p <= 0) priceErr = 'enterValidPrice';
    }

    if (!_hasValue(mileageController.text)) {
      mileageErr = 'required';
    } else {
      final m = int.tryParse(mileageController.text);
      if (m == null || m < 0) mileageErr = 'enterValidMileage';
    }

    state = state.copyWith(
      makeError: () => makeErr,
      modelError: () => modelErr,
      yearError: () => yearErr,
      plateError: () => plateErr,
      priceError: () => priceErr,
      mileageError: () => mileageErr,
    );
    return makeErr == null &&
        modelErr == null &&
        yearErr == null &&
        plateErr == null &&
        priceErr == null &&
        mileageErr == null;
  }

  void save(BuildContext context) {
    if (!validate()) return;
    final settings = ref.read(appSettingsProvider);
    final id = arg;
    final car = Car(
      id: id ?? 0,
      make: makeController.text.trim(),
      model: modelController.text.trim(),
      year: int.parse(yearController.text),
      plate: plateController.text.trim(),
      price: currencyToUsd(int.parse(priceController.text), settings.currency),
      mileage: int.parse(mileageController.text),
      color: state.colorIndex,
    );
    if (id != null) {
      ref.read(carsProvider.notifier).updateCar(car);
    } else {
      ref.read(carsProvider.notifier).addCar(car);
    }
    goToHome(context);
  }
}

final carFormProvider = NotifierProvider.autoDispose
    .family<CarFormNotifier, CarFormState, int?>(CarFormNotifier.new);
