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

  group('recalculateCarStats', () {
    late Database db;
    late SqliteCarsRepository repo;
    late SqliteCarWorksRepository worksRepo;

    setUp(() {
      db = sqlite3.openInMemory();
      repo = SqliteCarsRepository(db);
      worksRepo = SqliteCarWorksRepository(db);
    });

    tearDown(() => db.close());

    CarStats _stats(int carId) => repo.loadCarStats(carId);

    CarWork _work({
      int id = 0,
      int carId = 1,
      int date = 1000,
      int category = 0,
      int mileage = 30000,
      int cost = 200,
      String description = 'Work',
    }) =>
        CarWork(
          id: id,
          carId: carId,
          date: date,
          category: category,
          mileage: mileage,
          cost: cost,
          description: description,
        );

    test('with no works: totalSpent=0, lastOilChangeKm=-1, topCategory=-1', () {
      repo.insert(Car(
        id: 0,
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        color: 1,
        plate: 'ABC123',
        price: 25000,
        mileage: 75000,
      ));
      final car = repo.load().first;
      repo.saveCarStats(CarStats(carId: car.id, totalSpent: 999, lastOilChangeKm: 999));

      repo.recalculateCarStats(car.id);

      final stats = _stats(car.id);
      expect(stats.totalSpent, 0);
      expect(stats.lastOilChangeKm, -1);
      expect(stats.topCategory, -1);
    });

    test('sums costs and finds top category', () {
      repo.insert(Car(
        id: 0,
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        color: 1,
        plate: 'ABC123',
        price: 25000,
        mileage: 50000,
      ));
      final car = repo.load().first;
      repo.saveCarStats(CarStats(carId: car.id, totalSpent: 0, lastOilChangeKm: 0));

      worksRepo.insert(_work(carId: car.id, category: 0, cost: 150, description: 'Oil'));
      worksRepo.insert(_work(carId: car.id, category: 1, cost: 200, description: 'Fuel'));
      worksRepo.insert(_work(carId: car.id, category: 5, cost: 350, description: 'Repair'));

      repo.recalculateCarStats(car.id);

      final stats = _stats(car.id);
      expect(stats.totalSpent, 700);
      expect(stats.topCategory, 5); // repair has highest total
    });

    test('ignores works from other cars', () {
      repo.insert(Car(
        id: 0, make: 'Toyota', model: 'Camry', year: 2020,
        color: 1, plate: 'ABC123', price: 25000, mileage: 50000,
      ));
      repo.insert(Car(
        id: 0, make: 'Honda', model: 'Civic', year: 2021,
        color: 2, plate: 'XYZ789', price: 20000, mileage: 30000,
      ));
      final cars = repo.load();
      final car1 = cars[0];
      final car2 = cars[1];
      repo.saveCarStats(CarStats(carId: car1.id, totalSpent: 0, lastOilChangeKm: 0));
      repo.saveCarStats(CarStats(carId: car2.id, totalSpent: 0, lastOilChangeKm: 0));

      worksRepo.insert(_work(carId: car1.id, cost: 500, description: 'Car1 work'));
      worksRepo.insert(_work(carId: car2.id, cost: 300, description: 'Car2 work'));

      repo.recalculateCarStats(car1.id);

      expect(_stats(car1.id).totalSpent, 500);
      expect(_stats(car1.id).topCategory, 0); // only oil category
      // car2's stats are lazy-recalculated when loaded, discovering its work
      expect(_stats(car2.id).totalSpent, 300);
      expect(_stats(car2.id).topCategory, 0);
    });

    test('with oil work: lastOilChangeKm and topCategory', () {
      repo.insert(Car(
        id: 0, make: 'Toyota', model: 'Camry', year: 2020,
        color: 1, plate: 'ABC123', price: 25000, mileage: 80000,
      ));
      final car = repo.load().first;
      repo.saveCarStats(CarStats(carId: car.id, totalSpent: 0, lastOilChangeKm: 0));

      // Older oil change
      worksRepo.insert(_work(
        carId: car.id, date: 1000, mileage: 30000, cost: 150,
        description: 'Old oil',
      ));
      // Newer oil change
      worksRepo.insert(_work(
        carId: car.id, date: 2000, mileage: 45000, cost: 180,
        description: 'Recent oil',
      ));

      repo.recalculateCarStats(car.id);

      final stats = _stats(car.id);
      expect(stats.lastOilChangeKm, 45000);
      expect(stats.topCategory, 0); // only oil category
    });

    test('with non-oil works only: sentinels for oil stats, topCategory from spend', () {
      repo.insert(Car(
        id: 0, make: 'Toyota', model: 'Camry', year: 2020,
        color: 1, plate: 'ABC123', price: 25000, mileage: 60000,
      ));
      final car = repo.load().first;
      repo.saveCarStats(CarStats(carId: car.id, totalSpent: 0, lastOilChangeKm: 0));

      worksRepo.insert(_work(
        carId: car.id, category: 1, cost: 100, description: 'Fuel',
      ));
      worksRepo.insert(_work(
        carId: car.id, category: 5, cost: 400, description: 'Repair',
      ));

      repo.recalculateCarStats(car.id);

      final stats = _stats(car.id);
      expect(stats.totalSpent, 500);
      expect(stats.lastOilChangeKm, -1);
      expect(stats.topCategory, 5); // repair (400) > fuel (100)
    });

    test('topCategory uses category with highest total cost', () {
      repo.insert(Car(
        id: 0, make: 'Test', model: 'Car', year: 2020,
        color: 1, plate: 'TST', price: 10000, mileage: 50000,
      ));
      final car = repo.load().first;
      repo.saveCarStats(CarStats(carId: car.id, totalSpent: 0, lastOilChangeKm: 0));

      // category 1 has two works totalling 600
      worksRepo.insert(_work(carId: car.id, category: 1, cost: 250, description: 'Fuel A'));
      worksRepo.insert(_work(carId: car.id, category: 1, cost: 350, description: 'Fuel B'));
      // category 5 has one work totalling 500
      worksRepo.insert(_work(carId: car.id, category: 5, cost: 500, description: 'Repair'));

      repo.recalculateCarStats(car.id);

      final stats = _stats(car.id);
      expect(stats.topCategory, 1); // fuel totals 600 > repair 500
    });
  });
}
