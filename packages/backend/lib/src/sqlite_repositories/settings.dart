// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:sqlite3/sqlite3.dart';

import '../base_repository.dart';
import '../models/models.dart';

class SqliteSettingsRepository implements SettingsRepository {
  final Database _db;
  SqliteSettingsRepository(this._db) {
    _db.execute(SqlSettingsQueries.createTable);
    _db.execute(SqlSettingsQueries.insertDefault);
    // Migration: add oil_interval_km for DBs created before this column existed
    try {
      _db.execute(SqlSettingsQueries.addOilIntervalColumn);
    } catch (_) {}
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

class SqlSettingsQueries {
  SqlSettingsQueries._();

  static const int _rowId = 0;

  static const _columns =
      'language, distance_unit, theme, currency, oil_interval_km';
  static const _table = 'app_settings';

  // dart format off
  static const createTable = '''
CREATE TABLE IF NOT EXISTS $_table (
  id               INTEGER PRIMARY KEY CHECK (id = $_rowId),
  language         INTEGER DEFAULT 0,
  distance_unit    INTEGER DEFAULT 0,
  theme            INTEGER DEFAULT 0,
  currency         INTEGER DEFAULT 0,
  oil_interval_km  INTEGER DEFAULT 10000
)
''';

  static const insertDefault = '''
INSERT OR IGNORE INTO $_table (id) VALUES ($_rowId)
''';

  static const addOilIntervalColumn = '''
ALTER TABLE $_table ADD COLUMN oil_interval_km INTEGER DEFAULT 10000
''';

  static const load = '''
SELECT $_columns FROM $_table WHERE id = $_rowId
''';

  static const update = '''
UPDATE $_table SET
  language         = ?,
  distance_unit    = ?,
  theme            = ?,
  currency         = ?,
  oil_interval_km  = ?
WHERE id = $_rowId
''';
  // dart format on
}
