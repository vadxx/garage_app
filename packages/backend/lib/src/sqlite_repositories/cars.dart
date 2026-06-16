// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:sqlite3/sqlite3.dart';

import '../base_repository.dart';
import '../models/models.dart';
import 'cars_works.dart';

class SqliteCarsRepository implements CarsRepository {
  final Database _db;
  SqliteCarsRepository(this._db) {
    _db.execute(SqlCarsQueries.createTable);
    _db.execute(SqlCarsStatsQueries.createTable);
    _db.execute(SqlCarWorksQueries.createTable);
  }

  @override
  void delete(int carId) {
    _db.execute(SqlCarsStatsQueries.deleteCarStats, [carId]);
    _db.execute(SqlCarWorksQueries.deleteByCarId, [carId]);
    _db.execute(SqlCarsQueries.delete, [carId]);
  }

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

  @override
  CarStats loadCarStats(int carId) {
    final rows = _db.select(SqlCarsStatsQueries.loadCarStats, [carId]);
    assert(rows.isNotEmpty, 'CarStats row must exist for car $carId');
    return CarStats.fromSqlRow(rows.first.values);
  }

  @override
  void saveCarStats(CarStats stats) =>
      _db.execute(SqlCarsStatsQueries.saveCarStats, stats.toSqlRow());
}

class SqlCarsStatsQueries {
  SqlCarsStatsQueries._();

  static const _columns = 'car_id, total_spent, last_oil_change_km';
  static const _table = 'cars_stats';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  car_id INTEGER PRIMARY KEY,
  total_spent INTEGER DEFAULT 0,
  last_oil_change_km INTEGER DEFAULT 0
)
''';

  static const String loadCarStats = '''
SELECT * FROM $_table WHERE car_id = ?
''';

  static const String saveCarStats = '''
INSERT OR REPLACE INTO $_table ($_columns) VALUES (?, ?, ?)
''';

  static const String deleteCarStats = '''
DELETE FROM $_table WHERE car_id = ?
''';
  // dart format on
}

class SqlCarsQueries {
  SqlCarsQueries._();

  static const _columns = 'year, color, price, mileage, make, model, plate';
  static const _table = 'cars';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  year      INTEGER DEFAULT 0,
  color     INTEGER DEFAULT 0,
  price     INTEGER DEFAULT 0,
  mileage   INTEGER DEFAULT 0,
  make      TEXT NOT NULL,
  model     TEXT NOT NULL,
  plate     TEXT NOT NULL
)
''';

  static const String count = 'SELECT COUNT(*) as c FROM $_table';

  static const String load = 'SELECT id, $_columns FROM $_table ORDER BY id';

  static const insert = '''
INSERT INTO $_table ($_columns)
VALUES (?, ?, ?, ?, ?, ?, ?)
''';

  static const update = '''
UPDATE $_table SET
  year    = ?,
  color   = ?,
  price   = ?,
  mileage = ?,
  make    = ?,
  model   = ?,
  plate   = ?
WHERE id = ?
''';

  static const String delete = 'DELETE FROM $_table WHERE id = ?';
  // dart format on
}
