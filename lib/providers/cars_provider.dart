// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';
import 'repositories_provider.dart';

final carsProvider = NotifierProvider<CarsNotifier, List<Car>>(
  CarsNotifier.new,
);

class CarsNotifier extends Notifier<List<Car>> {
  @override
  List<Car> build() => ref.read(carsRepositoryProvider).load();

  void addCar(Car car) {
    final repo = ref.read(carsRepositoryProvider);
    repo.insert(car);
    state = repo.load();
  }

  void updateCar(Car car) {
    final repo = ref.read(carsRepositoryProvider);
    repo.update(car);
    state = repo.load();
  }

  void deleteCar(int carId) {
    final repo = ref.read(carsRepositoryProvider);
    repo.delete(carId);
    state = repo.load();
  }
}
