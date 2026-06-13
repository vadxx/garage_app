// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:backend/src/models/car.dart';
import 'package:sqlite3/sqlite3.dart';

import 'repository.dart';
import 'models/settings.dart';
import 'sql_queries.dart';

const String _dbFileName = 'garage.db';

class SqliteRepositories implements Repositories {
  @override
  SettingsRepository get settingsRepo => _settingsRepo;
  @override
  CarsRepository get carsRepo => _carsRepo;

  late final SettingsRepository _settingsRepo;
  late final CarsRepository _carsRepo;

  @override
  void init(String appStoragePath) {
    final fullPath = "$appStoragePath/$_dbFileName";
    final Database db = sqlite3.open(fullPath);
    _settingsRepo = SqliteSettingsRepository(db);
    _carsRepo = SqliteCarsRepository(db);
  }
}

class SqliteSettingsRepository implements SettingsRepository {
  final Database _db;
  SqliteSettingsRepository(this._db) {
    _db.execute(SqlSettingsQueries.createTable);
    _db.execute(SqlSettingsQueries.insertDefault);
  }

  @override
  AppSettings load() {
    final row = _db.select(SqlSettingsQueries.load).first;
    return AppSettings.fromSqlRow(row.values);
  }

  @override
  void save(AppSettings settings) =>
      _db.execute(SqlSettingsQueries.update, settings.toSqlRow());
}

class SqliteCarsRepository implements CarsRepository {
  final Database _db;
  SqliteCarsRepository(this._db) {
    _db.execute(SqlCarsQueries.createTable);
  }

  @override
  void delete(int carId) => _db.execute(SqlCarsQueries.delete, [carId]);

  @override
  void insert(Car car) => _db.execute(SqlCarsQueries.insert, car.toSqlRow());

  @override
  List<Car> load() => _db
      .select(SqlCarsQueries.load)
      .map((r) => Car.fromSqlRow(r.values))
      .toList();

  @override
  void update(Car car) =>
      _db.execute(SqlCarsQueries.update, [...car.toSqlRow(), car.id]);
}
