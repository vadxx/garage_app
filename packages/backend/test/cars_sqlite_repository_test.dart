// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:backend/backend.dart';
import 'package:backend/sqlite_backend.dart';

void main() {
  group('SqliteCarsRepository', () {
    late Database db;
    late SqliteCarsRepository repo;

    setUp(() {
      db = sqlite3.openInMemory();
      repo = SqliteCarsRepository(db);
    });

    tearDown(() => db.close());

    Car createCar() => Car(
      id: 0,
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      color: 1,
      plate: 'ABC123',
      price: 25000,
      mileage: 50000,
    );

    test('load returns empty list initially', () {
      expect(repo.load(), isEmpty);
    });

    test('insert adds a car', () {
      repo.insert(createCar());
      final cars = repo.load();
      expect(cars.length, 1);
      expect(cars[0].make, 'Toyota');
      expect(cars[0].model, 'Camry');
      expect(cars[0].id, greaterThan(0));
    });

    test('insert multiple cars returns in order', () {
      repo.insert(createCar());
      repo.insert(
        createCar().copyWith(make: 'Honda', model: 'Civic', plate: 'XYZ789'),
      );
      final cars = repo.load();
      expect(cars.length, 2);
      expect(cars[0].make, 'Toyota');
      expect(cars[1].make, 'Honda');
    });

    test('update modifies existing car', () {
      repo.insert(createCar());
      final car = repo.load().first;
      final updated = car.copyWith(make: 'Honda', price: 30000);
      repo.update(updated);
      final loaded = repo.load();
      expect(loaded.length, 1);
      expect(loaded[0].make, 'Honda');
      expect(loaded[0].price, 30000);
    });

    test('delete removes car by id', () {
      repo.insert(createCar());
      repo.insert(createCar().copyWith(plate: 'XYZ789'));
      final cars = repo.load();
      repo.delete(cars[0].id);
      expect(repo.load().length, 1);
    });

    test('delete non-existent id does nothing', () {
      repo.insert(createCar());
      repo.delete(999);
      expect(repo.load().length, 1);
    });
  });
}
