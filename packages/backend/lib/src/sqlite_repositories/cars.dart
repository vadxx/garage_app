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
    _db.execute(SqlCarColorsQueries.createTable);
    _db.execute(SqlCarColorsQueries.seed);
    // Migration: add top_category for DBs created before this column existed
    try {
      _db.execute(SqlCarsStatsQueries.addTopCategoryColumn);
    } catch (_) {}
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
  void insertWithId(Car car) =>
      _db.execute(SqlCarsQueries.insertWithId, [car.id, ...car.toSqlRow()]);

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
    var rows = _db.select(SqlCarsStatsQueries.loadCarStats, [carId]);
    if (rows.isEmpty) {
      saveCarStats(CarStats(carId: carId, totalSpent: 0, lastOilChangeKm: 0));
      recalculateCarStats(carId);
      rows = _db.select(SqlCarsStatsQueries.loadCarStats, [carId]);
    } else {
      final existing = CarStats.fromSqlRow(rows.first.values);
      if (existing.topCategory == -1) {
        recalculateCarStats(carId);
        rows = _db.select(SqlCarsStatsQueries.loadCarStats, [carId]);
      }
    }
    assert(rows.isNotEmpty, 'CarStats row must exist for car $carId');
    return CarStats.fromSqlRow(rows.first.values);
  }

  @override
  void saveCarStats(CarStats stats) =>
      _db.execute(SqlCarsStatsQueries.saveCarStats, stats.toSqlRow());

  @override
  void recalculateCarStats(int carId) => _db.execute(
    SqlCarsStatsQueries.recalculateTotalSpent,
    [carId, carId, carId, carId],
  );

  @override
  String colorName(int id) {
    final rows = _db.select(SqlCarColorsQueries.nameById, [id]);
    return rows.isNotEmpty ? rows.first.values.first as String : '';
  }

  @override
  int colorId(String name) {
    final rows = _db.select(SqlCarColorsQueries.idByName, [name]);
    return rows.isNotEmpty ? rows.first.values.first as int : 0;
  }
}

class SqlCarColorsQueries {
  SqlCarColorsQueries._();

  static const createTable = '''
CREATE TABLE IF NOT EXISTS car_colors (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
)
''';

  static const seed = '''
INSERT OR IGNORE INTO car_colors (id, name) VALUES
  (0, 'white'), (1, 'black'), (2, 'silver'), (3, 'blue'), (4, 'red'),
  (5, 'green'), (6, 'yellow'), (7, 'orange'), (8, 'purple'), (9, 'brown')
''';

  static const String nameById = 'SELECT name FROM car_colors WHERE id = ?';
  static const String idByName = 'SELECT id FROM car_colors WHERE name = ?';
}

class SqlCarsStatsQueries {
  SqlCarsStatsQueries._();

  static const _columns = 'car_id, total_spent, last_oil_change_km, top_category';
  static const _table = 'cars_stats';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  car_id INTEGER PRIMARY KEY,
  total_spent INTEGER DEFAULT 0,
  last_oil_change_km INTEGER DEFAULT 0,
  top_category INTEGER DEFAULT -1
)
''';

  static const addTopCategoryColumn = '''
ALTER TABLE $_table ADD COLUMN top_category INTEGER DEFAULT -1
''';

  static const String loadCarStats = '''
SELECT * FROM $_table WHERE car_id = ?
''';

  static const String saveCarStats = '''
INSERT OR REPLACE INTO $_table ($_columns) VALUES (?, ?, ?, ?)
''';

  static const String deleteCarStats = '''
DELETE FROM $_table WHERE car_id = ?
''';

  static const String recalculateTotalSpent = '''
UPDATE $_table
SET
  total_spent = (SELECT COALESCE(SUM(cost), 0) FROM car_works WHERE car_id = ?),
  last_oil_change_km = COALESCE(
    (SELECT mileage FROM car_works WHERE car_id = ? AND category = 0 ORDER BY date DESC, id DESC LIMIT 1),
    -1
  ),
  top_category = COALESCE(
    (SELECT category FROM car_works WHERE car_id = ? GROUP BY category ORDER BY SUM(cost) DESC LIMIT 1),
    -1
  )
WHERE car_id = ?
''';
  // dart format on
}

class SqlCarsQueries {
  SqlCarsQueries._();

  static const _columns = 'year, color, price, mileage, make, model, plate';
  static const _columnsWithId = 'id, $_columns';
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

  static const insertWithId = '''
INSERT INTO $_table ($_columnsWithId)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
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
