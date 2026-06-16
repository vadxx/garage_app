// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:sqlite3/sqlite3.dart';

import '../../backend.dart';

class SqliteCarWorksRepository implements CarWorksRepository {
  final Database _db;
  SqliteCarWorksRepository(this._db) {
    _db.execute(SqlCarWorksQueries.createTable);
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
  void update(CarWork work) =>
      _db.execute(SqlCarWorksQueries.update, [...work.toSqlRow(), work.id]);

  @override
  void delete(int workId) => _db.execute(SqlCarWorksQueries.delete, [workId]);
}

class SqlCarWorksQueries {
  SqlCarWorksQueries._();

  static const _columns = 'car_id, date, category, mileage, cost, description';
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
