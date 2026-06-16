// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:backend/backend.dart';
import 'package:backend/sqlite_backend.dart';

void main() {
  group('SqliteCarWorksRepository', () {
    late Database db;
    late SqliteCarWorksRepository repo;

    setUp(() {
      db = sqlite3.openInMemory();
      repo = SqliteCarWorksRepository(db);
    });

    tearDown(() => db.close());

    CarWork createWork({int carId = 1, int? id}) {
      return CarWork(
        id: id ?? 0,
        carId: carId,
        date: 1700000000,
        category: 0,
        mileage: 50000,
        cost: 200,
        description: 'Oil change',
      );
    }

    test('loadByCarId returns empty initially', () {
      expect(repo.loadByCarId(1), isEmpty);
    });

    test('insert adds a work', () {
      repo.insert(createWork());
      final works = repo.loadByCarId(1);
      expect(works.length, 1);
      expect(works[0].description, 'Oil change');
      expect(works[0].cost, 200);
      expect(works[0].id, greaterThan(0));
    });

    test('loadByCarId returns only works for given car', () {
      repo.insert(createWork(carId: 1));
      repo.insert(createWork(carId: 2));
      expect(repo.loadByCarId(1).length, 1);
      expect(repo.loadByCarId(2).length, 1);
    });

    test('loadByCarId orders by date descending', () {
      repo.insert(createWork(carId: 1).copyWith(date: 100));
      repo.insert(createWork(carId: 1).copyWith(date: 200));
      final works = repo.loadByCarId(1);
      expect(works.length, 2);
      expect(works[0].date, 200);
      expect(works[1].date, 100);
    });

    test('update modifies existing work', () {
      repo.insert(createWork());
      final work = repo.loadByCarId(1).first;
      repo.update(work.copyWith(cost: 350, description: 'Full service'));
      final loaded = repo.loadByCarId(1);
      expect(loaded.length, 1);
      expect(loaded[0].cost, 350);
      expect(loaded[0].description, 'Full service');
    });

    test('delete removes work by id', () {
      repo.insert(createWork());
      repo.insert(createWork(carId: 1).copyWith(description: 'Tire change'));
      final works = repo.loadByCarId(1);
      repo.delete(works[0].id);
      expect(repo.loadByCarId(1).length, 1);
    });

    test('delete non-existent id does nothing', () {
      repo.insert(createWork());
      repo.delete(999);
      expect(repo.loadByCarId(1).length, 1);
    });
  });
}
