// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/backend.dart';

abstract class Repositories {
  void init(String appStoragePath);
  SettingsRepository get settingsRepo;
  CarsRepository get carsRepo;
  CarWorksRepository get carWorksRepo;

  /// Run [action] inside a transaction. If [action] throws, all changes
  /// made within the transaction are rolled back.
  void transaction(void Function() action);
}

abstract class SettingsRepository {
  AppSettings load();
  void save(AppSettings settings);
}

abstract class CarWorksRepository {
  List<CarWork> loadByCarId(int carId);
  void insert(CarWork work);
  void insertWithId(CarWork work);
  void update(CarWork work);
  void delete(int workId);

  String categoryName(int id);
  int categoryId(String name);
}

abstract class CarsRepository {
  List<Car> load();
  void insert(Car car);
  void insertWithId(Car car);
  void update(Car car);
  void delete(int carId);

  CarStats loadCarStats(int carId);
  void saveCarStats(CarStats stats);
  void recalculateCarStats(int carId);

  String colorName(int id);
  int colorId(String name);
}
