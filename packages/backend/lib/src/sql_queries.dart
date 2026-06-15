// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

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

class SqlSettingsQueries {
  SqlSettingsQueries._();

  static const int _rowId = 0;

  static const _columns = 'language, distance_unit, theme, currency';
  static const _table = 'app_settings';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  id            INTEGER PRIMARY KEY CHECK (id = $_rowId),
  language      INTEGER DEFAULT 0,
  distance_unit INTEGER DEFAULT 0,
  theme         INTEGER DEFAULT 0,
  currency      INTEGER DEFAULT 0
)
''';

  static const insertDefault = '''
INSERT OR IGNORE INTO $_table (id) VALUES ($_rowId)
''';

  static const load = '''
SELECT $_columns FROM $_table WHERE id = $_rowId
''';

  static const update = '''
UPDATE $_table SET
  language      = ?,
  distance_unit = ?,
  theme         = ?,
  currency      = ?
WHERE id = $_rowId
''';
  // dart format on
}
