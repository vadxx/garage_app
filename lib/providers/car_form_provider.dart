// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';

import 'cars_provider.dart';
import '../app_router.dart';

class CarFormState {
  final String make;
  final String model;
  final String year;
  final String plate;
  final String price;
  final String mileage;
  final int colorIndex;
  final String? makeError;
  final String? modelError;
  final String? yearError;

  const CarFormState({
    this.make = '',
    this.model = '',
    this.year = '',
    this.plate = '',
    this.price = '',
    this.mileage = '',
    this.colorIndex = 0,
    this.makeError,
    this.modelError,
    this.yearError,
  });

  CarFormState copyWith({
    String? make,
    String? model,
    String? year,
    String? plate,
    String? price,
    String? mileage,
    int? colorIndex,
    String? Function()? makeError,
    String? Function()? modelError,
    String? Function()? yearError,
  }) => CarFormState(
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    plate: plate ?? this.plate,
    price: price ?? this.price,
    mileage: mileage ?? this.mileage,
    colorIndex: colorIndex ?? this.colorIndex,
    makeError: makeError != null ? makeError() : this.makeError,
    modelError: modelError != null ? modelError() : this.modelError,
    yearError: yearError != null ? yearError() : this.yearError,
  );
}

class CarFormNotifier extends AutoDisposeNotifier<CarFormState> {
  late final TextEditingController makeController;
  late final TextEditingController modelController;
  late final TextEditingController yearController;
  late final TextEditingController plateController;
  late final TextEditingController priceController;
  late final TextEditingController mileageController;

  @override
  CarFormState build() {
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
    return const CarFormState();
  }

  void loadCar(Car car) {
    makeController.text = car.make;
    modelController.text = car.model;
    yearController.text = car.year.toString();
    plateController.text = car.plate;
    priceController.text = car.price.toString();
    mileageController.text = car.mileage.toString();
    state = CarFormState(
      make: car.make,
      model: car.model,
      year: car.year.toString(),
      plate: car.plate,
      price: car.price.toString(),
      mileage: car.mileage.toString(),
      colorIndex: car.color,
    );
  }

  void setMake(String v) =>
      state = state.copyWith(make: v, makeError: () => null);
  void setModel(String v) =>
      state = state.copyWith(model: v, modelError: () => null);
  void setYear(String v) =>
      state = state.copyWith(year: v, yearError: () => null);
  void setPlate(String v) => state = state.copyWith(plate: v);
  void setPrice(String v) => state = state.copyWith(price: v);
  void setMileage(String v) => state = state.copyWith(mileage: v);
  void setColor(int v) => state = state.copyWith(colorIndex: v);

  bool _hasValue(String v) => v.trim().isNotEmpty;

  bool validate() {
    final now = currentYear;
    String? makeErr, modelErr, yearErr;

    if (!_hasValue(state.make)) makeErr = 'Required';
    if (!_hasValue(state.model)) modelErr = 'Required';

    if (!_hasValue(state.year)) {
      yearErr = 'Required';
    } else {
      final y = int.tryParse(state.year);
      if (y == null) {
        yearErr = 'Enter a valid year';
      } else if (y < minYear || y > now) {
        yearErr = 'Year must be $minYear–$now';
      }
    }

    state = state.copyWith(
      makeError: () => makeErr,
      modelError: () => modelErr,
      yearError: () => yearErr,
    );
    return makeErr == null && modelErr == null && yearErr == null;
  }

  void save(BuildContext context, {int? carId}) {
    if (!validate()) return;

    final car = Car(
      id: carId ?? 0,
      make: state.make.trim(),
      model: state.model.trim(),
      year: int.parse(state.year),
      plate: state.plate.trim(),
      price: int.tryParse(state.price) ?? 0,
      mileage: int.tryParse(state.mileage) ?? 0,
      color: state.colorIndex,
    );

    if (carId != null) {
      ref.read(carsProvider.notifier).updateCar(car);
    } else {
      ref.read(carsProvider.notifier).addCar(car);
    }

    goToHome(context);
  }
}

final carFormProvider =
    NotifierProvider.autoDispose<CarFormNotifier, CarFormState>(
      CarFormNotifier.new,
    );
