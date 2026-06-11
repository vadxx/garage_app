// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

class SqlCarsQueries {
  SqlCarsQueries._();

  static const _table = 'cars';

  // dart format off
  static const createTable = '''
''';

  static const String countCars = 'SELECT COUNT(*) as c FROM $_table';
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
