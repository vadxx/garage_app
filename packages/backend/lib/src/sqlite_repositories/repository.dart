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
  Database? _db;

  @override
  void init(String appStoragePath) {
    final fullPath = "$appStoragePath/$_dbFileName";
    _db = sqlite3.open(fullPath);
    final db = _db!;
    _settingsRepo = SqliteSettingsRepository(db);
    _carsRepo = SqliteCarsRepository(db);
    _carWorksRepo = SqliteCarWorksRepository(db);
  }

  @override
  void transaction(void Function() action) {
    final db = _db;
    if (db == null) {
      // Not initialized — cannot open a transaction.
      action();
      return;
    }
    db.execute('BEGIN');
    try {
      action();
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  static const String _dbFileName = 'garage.db';
}
