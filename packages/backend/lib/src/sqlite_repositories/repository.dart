// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:sqlite3/sqlite3.dart';

import '../base_repository.dart';

import 'settings.dart';
import 'cars.dart';
import 'cars_works.dart';

class SqliteRepositories implements Repositories {
  @override
  SettingsRepository get settingsRepo => _settingsRepo;
  @override
  CarsRepository get carsRepo => _carsRepo;
  @override
  CarWorksRepository get carWorksRepo => _carWorksRepo;

  late final SettingsRepository _settingsRepo;
  late final CarsRepository _carsRepo;
  late final CarWorksRepository _carWorksRepo;

  @override
  void init(String appStoragePath) {
    final fullPath = "$appStoragePath/$_dbFileName";
    final Database db = sqlite3.open(fullPath);
    _settingsRepo = SqliteSettingsRepository(db);
    _carsRepo = SqliteCarsRepository(db);
    _carWorksRepo = SqliteCarWorksRepository(db);
  }

  static const String _dbFileName = 'garage.db';
}
