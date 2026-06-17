// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/common.dart';
import 'package:csv/csv.dart';

import 'package:backend/backend.dart';
import 'package:backend/sqlite_backend.dart';

class _TestRepositories implements Repositories {
  @override
  final CarsRepository carsRepo;
  @override
  final CarWorksRepository carWorksRepo;
  @override
  final SettingsRepository settingsRepo;
  final CommonDatabase? _db;

  _TestRepositories(this.carsRepo, this.carWorksRepo, this.settingsRepo)
    : _db = null;

  _TestRepositories.withDb(
    this.carsRepo,
    this.carWorksRepo,
    this.settingsRepo,
    this._db,
  );

  @override
  void init(String _) {}

  @override
  void transaction(void Function() action) {
    final db = _db;
    if (db == null) {
      action();
      return;
    }
    db.execute('BEGIN');
    try {
      action();
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}

void main() {
  Car createCar({int id = 0, int color = 0, String make = 'Toyota'}) {
    return Car(
      id: id,
      year: 2020,
      color: color,
      price: 15000,
      mileage: 50000,
      make: make,
      model: 'Corolla',
      plate: 'ABC123',
    );
  }

  CarWork createWork({
    int carId = 1,
    int category = 0,
    int date = 1718452800,
    String description = 'Oil change',
  }) {
    return CarWork(
      id: 0,
      carId: carId,
      date: date,
      category: category,
      mileage: 50000,
      cost: 200,
      description: description,
    );
  }

  CarStats makeStats(int carId) =>
      CarStats(carId: carId, totalSpent: 5000, lastOilChangeKm: 30000);

  /// Build a CSV row matching the header, using CsvEncoder (round-trips safely).
  List<dynamic> row({
    int carId = 1,
    String make = 'Toyota',
    String model = 'Corolla',
    int year = 2020,
    String color = 'red',
    String plate = 'ABC123',
    int price = 15000,
    int carMileage = 50000,
    int totalSpent = 5000,
    int lastOilChangeKm = 30000,
    int? workId,
    String workDate = '',
    String workCategory = '',
    int workMileage = 0,
    int workCost = 0,
    String workDescription = '',
  }) {
    final r = [
      carId,
      make,
      model,
      year,
      color,
      plate,
      price,
      carMileage,
      totalSpent,
      lastOilChangeKm,
    ];
    if (workId != null) {
      r.addAll([
        workId,
        workDate,
        workCategory,
        workMileage,
        workCost,
        workDescription,
      ]);
    } else {
      r.addAll(['', '', '', '', '', '']);
    }
    return r;
  }

  String toCsv(List<List<dynamic>> rows) => const CsvEncoder().convert(rows);

  group('CsvService exportCsv', () {
    late Database db;
    late SqliteCarsRepository carsRepo;
    late SqliteCarWorksRepository carWorksRepo;
    late _TestRepositories repos;

    setUp(() {
      db = sqlite3.openInMemory();
      carsRepo = SqliteCarsRepository(db);
      carWorksRepo = SqliteCarWorksRepository(db);
      repos = _TestRepositories(
        carsRepo,
        carWorksRepo,
        SqliteSettingsRepository(db),
      );
    });

    tearDown(() => db.close());

    test('headers are the first row', () {
      final csv = CsvService.exportCsv(repos);
      expect(csv.startsWith(CsvService.headers.join(',')), isTrue);
    });

    test(
      'exports a car with no works as a single row with empty work columns',
      () {
        carsRepo.insert(createCar());
        final carId = carsRepo.load().first.id;
        carsRepo.saveCarStats(makeStats(carId));
        final csv = CsvService.exportCsv(repos);
        final rows = csv.split('\n').where((r) => r.isNotEmpty).toList();
        expect(rows.length, 2);
        final cols = rows[1].split(',');
        expect(cols[1], 'Toyota');
        expect(cols[14], isEmpty);
        expect(cols[15], isEmpty);
      },
    );

    test('exports a car with multiple works as multiple rows', () {
      carsRepo.insert(createCar());
      final carId = carsRepo.load().first.id;
      carsRepo.saveCarStats(makeStats(carId));
      carWorksRepo.insert(createWork(carId: carId));
      carWorksRepo.insert(createWork(carId: carId, category: 1));
      final csv = CsvService.exportCsv(repos);
      final rows = csv.split('\n').where((r) => r.isNotEmpty).toList();
      expect(rows.length, 3);
    });

    test('exports color as name, not index', () {
      carsRepo.insert(createCar(color: 4));
      final carId = carsRepo.load().first.id;
      carsRepo.saveCarStats(makeStats(carId));
      final csv = CsvService.exportCsv(repos);
      final cols = csv.split('\n')[1].split(',');
      expect(cols[4], 'red');
    });

    test('exports date as YYYY-MM-DD format', () {
      carsRepo.insert(createCar());
      final carId = carsRepo.load().first.id;
      carsRepo.saveCarStats(makeStats(carId));
      carWorksRepo.insert(
        createWork(carId: carId, date: 1718452800),
      ); // 2024-06-15 noon UTC
      final csv = CsvService.exportCsv(repos);
      final cols = csv.split('\n')[1].split(',');
      expect(cols[11], '2024-06-15');
    });

    test('exports category as name, not index', () {
      carsRepo.insert(createCar());
      final carId = carsRepo.load().first.id;
      carsRepo.saveCarStats(makeStats(carId));
      carWorksRepo.insert(createWork(carId: carId, category: 3));
      final csv = CsvService.exportCsv(repos);
      final cols = csv.split('\n')[1].split(',');
      expect(cols[12], 'diagnostic');
    });
  });

  group('CsvService importCsv', () {
    late Database db;
    late SqliteCarsRepository carsRepo;
    late SqliteCarWorksRepository carWorksRepo;
    late _TestRepositories repos;

    setUp(() {
      db = sqlite3.openInMemory();
      carsRepo = SqliteCarsRepository(db);
      carWorksRepo = SqliteCarWorksRepository(db);
      repos = _TestRepositories.withDb(
        carsRepo,
        carWorksRepo,
        SqliteSettingsRepository(db),
        db,
      );
    });

    tearDown(() => db.close());

    test('imports CSV with car and works', () {
      final csv = toCsv([
        CsvService.headers,
        row(
          workId: 1,
          workDate: '2023-11-14',
          workCategory: 'oil',
          workMileage: 50000,
          workCost: 200,
          workDescription: 'Oil change',
        ),
      ]);

      CsvService.importCsv(repos, csv);
      final cars = carsRepo.load();
      expect(cars.length, 1);
      expect(cars[0].make, 'Toyota');
      expect(cars[0].color, 4);
      final works = carWorksRepo.loadByCarId(cars[0].id);
      expect(works.length, 1);
      expect(works[0].description, 'Oil change');
      expect(works[0].category, 0);
    });

    test('imports CSV with a car that has no works', () {
      final csv = toCsv([CsvService.headers, row()]);

      CsvService.importCsv(repos, csv);
      final cars = carsRepo.load();
      expect(cars.length, 1);
      final works = carWorksRepo.loadByCarId(cars[0].id);
      expect(works, isEmpty);
    });

    test('imports CSV with multiple cars and multiple works', () {
      final csv = toCsv([
        CsvService.headers,
        row(
          carId: 1,
          workId: 1,
          workDate: '2023-01-01',
          workCategory: 'oil',
          workMileage: 50000,
          workCost: 200,
          workDescription: 'Oil',
        ),
        row(
          carId: 1,
          workId: 2,
          workDate: '2023-06-01',
          workCategory: 'repair',
          workMileage: 60000,
          workCost: 500,
          workDescription: 'Fix',
        ),
        row(
          carId: 2,
          make: 'Honda',
          model: 'Civic',
          plate: 'XYZ789',
          color: 'blue',
          price: 20000,
          carMileage: 30000,
          totalSpent: 1000,
          lastOilChangeKm: 15000,
          workId: 3,
          workDate: '2023-03-01',
          workCategory: 'fuel',
          workMileage: 30000,
          workCost: 100,
          workDescription: 'Gas',
        ),
      ]);

      CsvService.importCsv(repos, csv);
      expect(carsRepo.load().length, 2);
      expect(carWorksRepo.loadByCarId(1).length, 2);
      expect(carWorksRepo.loadByCarId(2).length, 1);
    });

    test('maps color name to correct id', () {
      final csv = toCsv([CsvService.headers, row(color: 'blue')]);

      CsvService.importCsv(repos, csv);
      expect(carsRepo.load().first.color, 3);
    });

    test('maps category name to correct id', () {
      final csv = toCsv([
        CsvService.headers,
        row(
          workId: 1,
          workDate: '2023-01-01',
          workCategory: 'repair',
          workMileage: 10000,
          workCost: 100,
          workDescription: 'x',
        ),
      ]);

      CsvService.importCsv(repos, csv);
      expect(carWorksRepo.loadByCarId(1).first.category, 5);
    });

    test('throws StateError when database already has data', () {
      carsRepo.insert(
        Car(
          id: 0,
          year: 2020,
          color: 0,
          price: 0,
          mileage: 0,
          make: 'M',
          model: 'M',
          plate: 'P',
        ),
      );
      final csv = toCsv([CsvService.headers, row()]);

      expect(() => CsvService.importCsv(repos, csv), throwsStateError);
    });

    test('throws FormatException for missing required column', () {
      final csv = toCsv([
        ['car_id', 'make', 'model', 'year', 'color', 'plate'],
        row().sublist(0, 6),
      ]);

      expect(() => CsvService.importCsv(repos, csv), throwsFormatException);
    });

    test('throws FormatException for invalid integer in data', () {
      final csv = toCsv([
        CsvService.headers,
        row(price: -1)..[6] = 'not-a-number',
      ]);

      expect(() => CsvService.importCsv(repos, csv), throwsFormatException);
    });

    test('throws FormatException for invalid date format', () {
      final csv = toCsv([
        CsvService.headers,
        row(
          workId: 1,
          workDate: 'not-a-date',
          workCategory: 'oil',
          workMileage: 100,
          workCost: 100,
          workDescription: 'x',
        ),
      ]);

      expect(() => CsvService.importCsv(repos, csv), throwsFormatException);
    });

    test('rolls back all data when import fails mid-way', () {
      // Two cars, second has an invalid date — entire import must roll back.
      final csv = toCsv([
        CsvService.headers,
        row(
          carId: 1,
          workId: 1,
          workDate: '2024-06-15',
          workCategory: 'oil',
          workMileage: 50000,
          workCost: 200,
          workDescription: 'Valid work',
        ),
        row(
          carId: 2,
          make: 'Honda',
          model: 'Civic',
          plate: 'XYZ789',
          color: 'blue',
          workId: 2,
          workDate: 'not-a-date',
          workCategory: 'fuel',
          workMileage: 100,
          workCost: 50,
          workDescription: 'Bad date',
        ),
      ]);

      expect(() => CsvService.importCsv(repos, csv), throwsFormatException);
      // DB should remain empty — car 1 must not be present.
      expect(carsRepo.load(), isEmpty);
    });

    test('round-trips: export then import into empty DB', () {
      carsRepo.insert(createCar());
      final carId = carsRepo.load().first.id;
      carsRepo.saveCarStats(makeStats(carId));
      carWorksRepo.insert(createWork(carId: carId));
      carWorksRepo.insert(
        createWork(carId: carId, category: 1, description: 'Fuel up'),
      );

      final csv = CsvService.exportCsv(repos);

      final db2 = sqlite3.openInMemory();
      final carsRepo2 = SqliteCarsRepository(db2);
      final carWorksRepo2 = SqliteCarWorksRepository(db2);
      final repos2 = _TestRepositories.withDb(
        carsRepo2,
        carWorksRepo2,
        SqliteSettingsRepository(db2),
        db2,
      );

      CsvService.importCsv(repos2, csv);

      expect(carsRepo2.load().length, 1);
      expect(carsRepo2.load().first.make, 'Toyota');
      expect(carWorksRepo2.loadByCarId(1).length, 2);
      expect(carWorksRepo2.loadByCarId(1).first.description, 'Oil change');

      db2.close();
    });
  });
}
