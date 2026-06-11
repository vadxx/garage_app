// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/backend.dart';

abstract class Repositories {
  void init(String appStoragePath);
  SettingsRepository get settingsRepo;
  CarsRepository get carsRepo;
}

abstract class SettingsRepository {
  AppSettings load();
  void save(AppSettings settings);
}

abstract class CarsRepository {
  // List<Car> loadCars()
  // void insertCar(Car car)
  // void updateCar(Car car)
  // void deleteCar(int carId)
}