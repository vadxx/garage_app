// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:sqlite3/sqlite3.dart';

import '../../backend.dart';

class SqliteCarWorksRepository implements CarWorksRepository {
  final Database _db;
  SqliteCarWorksRepository(this._db) {
    _db.execute(SqlCarWorksQueries.createTable);
    _db.execute(SqlCarWorkCategoriesQueries.createTable);
    _db.execute(SqlCarWorkCategoriesQueries.seed);
  }

  @override
  List<CarWork> loadByCarId(int carId) => _db
      .select(SqlCarWorksQueries.loadByCarId, [carId])
      .map((r) => CarWork.fromSqlRow(r.values))
      .toList();

  @override
  void insert(CarWork work) =>
      _db.execute(SqlCarWorksQueries.insert, work.toSqlRow());

  @override
  void insertWithId(CarWork work) => _db.execute(
    SqlCarWorksQueries.insertWithId,
    [work.id, ...work.toSqlRow()],
  );

  @override
  void update(CarWork work) =>
      _db.execute(SqlCarWorksQueries.update, [...work.toSqlRow(), work.id]);

  @override
  void delete(int workId) => _db.execute(SqlCarWorksQueries.delete, [workId]);

  @override
  String categoryName(int id) {
    final rows = _db.select(SqlCarWorkCategoriesQueries.nameById, [id]);
    return rows.isNotEmpty ? rows.first.values.first as String : '';
  }

  @override
  int categoryId(String name) {
    final rows = _db.select(SqlCarWorkCategoriesQueries.idByName, [name]);
    return rows.isNotEmpty ? rows.first.values.first as int : 0;
  }
}

class SqlCarWorksQueries {
  SqlCarWorksQueries._();

  static const _columns = 'car_id, date, category, mileage, cost, description';
  static const _columnsWithId = 'id, $_columns';
  static const _selectColumns = 'id, $_columns';
  static const _table = 'car_works';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  car_id      INTEGER NOT NULL,
  date        INTEGER NOT NULL,
  category    INTEGER NOT NULL,
  mileage     INTEGER NOT NULL,
  cost        INTEGER NOT NULL,
  description TEXT NOT NULL
)
''';

  static const String loadByCarId = '''
SELECT $_selectColumns FROM $_table WHERE car_id = ? ORDER BY date DESC
''';

  static const insert = '''
INSERT INTO $_table ($_columns) VALUES (?, ?, ?, ?, ?, ?)
''';

  static const insertWithId = '''
INSERT INTO $_table ($_columnsWithId) VALUES (?, ?, ?, ?, ?, ?, ?)
''';

  static const update = '''
UPDATE $_table SET
  car_id      = ?,
  date        = ?,
  category    = ?,
  mileage     = ?,
  cost        = ?,
  description = ?
WHERE id = ?
''';

  static const String delete = 'DELETE FROM $_table WHERE id = ?';

  static const String deleteByCarId = 'DELETE FROM $_table WHERE car_id = ?';
  // dart format on
}

class SqlCarWorkCategoriesQueries {
  SqlCarWorkCategoriesQueries._();

  static const createTable = '''
CREATE TABLE IF NOT EXISTS car_work_categories (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
)
''';

  static const seed = '''
INSERT OR IGNORE INTO car_work_categories (id, name) VALUES
  (0, 'oil'), (1, 'fuel'), (2, 'cleaning'), (3, 'diagnostic'),
  (4, 'electronics'), (5, 'repair'), (6, 'replacement'), (7, 'parking'),
  (8, 'insurance'), (9, 'tiresWheels'), (10, 'taxFees')
''';

  static const String nameById =
      'SELECT name FROM car_work_categories WHERE id = ?';
  static const String idByName =
      'SELECT id FROM car_work_categories WHERE name = ?';
}
