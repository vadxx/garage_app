// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:backend/backend.dart';
import 'package:backend/sqlite_backend.dart';

void main() {
  group('SqliteSettingsRepository', () {
    late Database db;
    late SqliteSettingsRepository repo;

    setUp(() {
      db = sqlite3.openInMemory();
      repo = SqliteSettingsRepository(db);
    });

    tearDown(() => db.close());

    test('load returns defaults', () {
      final s = repo.load();
      expect(s.language, Language.en);
      expect(s.distanceUnit, DistanceUnit.km);
      expect(s.theme, Theme.system);
      expect(s.currency, Currency.usd);
    });

    test('save and load round-trip all fields', () {
      final updated = AppSettings(
        language: Language.ru,
        distanceUnit: DistanceUnit.mi,
        theme: Theme.dark,
        currency: Currency.eur,
      );
      repo.save(updated);

      final loaded = repo.load();
      expect(loaded.language, Language.ru);
      expect(loaded.distanceUnit, DistanceUnit.mi);
      expect(loaded.theme, Theme.dark);
      expect(loaded.currency, Currency.eur);
    });

    test('overwrites previous values', () {
      repo.save(AppSettings(language: Language.ru));
      expect(repo.load().language, Language.ru);

      repo.save(AppSettings(language: Language.en));
      expect(repo.load().language, Language.en);
    });
  });
}
