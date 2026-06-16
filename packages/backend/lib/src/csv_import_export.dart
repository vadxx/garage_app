import 'package:csv/csv.dart';

import 'base_repository.dart';
import 'models/models.dart';
import 'utils/date_utils.dart';

class CsvService {
  static List<String> get headers => _headers;

  static const _headers = [
    'car_id',
    'make',
    'model',
    'year',
    'color',
    'plate',
    'price',
    'car_mileage',
    'total_spent',
    'last_oil_change_km',
    'work_id',
    'work_date',
    'work_category',
    'work_mileage',
    'work_cost',
    'work_description',
  ];

  static String exportCsv(Repositories repos) {
    final cars = repos.carsRepo.load();
    final rows = <List<dynamic>>[_headers];

    for (final car in cars) {
      final stats = repos.carsRepo.loadCarStats(car.id);
      final works = repos.carWorksRepo.loadByCarId(car.id);
      final colorName = repos.carsRepo.colorName(car.color);

      if (works.isEmpty) {
        rows.add([
          car.id,
          car.make,
          car.model,
          car.year,
          colorName,
          car.plate,
          car.price,
          car.mileage,
          stats.totalSpent,
          stats.lastOilChangeKm,
          '',
          '',
          '',
          '',
          '',
          '',
        ]);
      } else {
        for (final work in works) {
          rows.add([
            car.id,
            car.make,
            car.model,
            car.year,
            colorName,
            car.plate,
            car.price,
            car.mileage,
            stats.totalSpent,
            stats.lastOilChangeKm,
            work.id,
            formatEpochDate(work.date),
            repos.carWorksRepo.categoryName(work.category),
            work.mileage,
            work.cost,
            work.description,
          ]);
        }
      }
    }

    return const CsvEncoder().convert(rows);
  }

  static void importCsv(Repositories repos, String csvContent) {
    final rows = const CsvDecoder().convert(csvContent);
    if (rows.length < 2) {
      throw FormatException('CSV file has no data rows.');
    }

    final headerRow = rows.first.map((c) => c.toString()).toList();
    final dataRows = rows.skip(1).toList();

    if (repos.carsRepo.load().isNotEmpty) {
      throw StateError('Database is not empty. Clear data first.');
    }

    final colIndex = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      colIndex[headerRow[i]] = i;
    }

    for (final col in _headers) {
      if (!colIndex.containsKey(col)) {
        throw FormatException('Missing required column: $col');
      }
    }

    final carGroups = <int, List<List<dynamic>>>{};
    for (var ri = 0; ri < dataRows.length; ri++) {
      final row = dataRows[ri];
      _validateRowLength(row, ri, headerRow.length);
      final carId = _parseInt(row[colIndex['car_id']!], 'car_id', ri);
      carGroups.putIfAbsent(carId, () => []).add(row);
    }

    for (final entry in carGroups.entries) {
      final firstRow = entry.value.first;

      final carId = _parseInt(firstRow[colIndex['car_id']!], 'car_id');
      final make = firstRow[colIndex['make']!].toString();
      final model = firstRow[colIndex['model']!].toString();
      final year = _parseInt(firstRow[colIndex['year']!], 'year');
      final colorName = firstRow[colIndex['color']!].toString();
      final plate = firstRow[colIndex['plate']!].toString();
      final price = _parseInt(firstRow[colIndex['price']!], 'price');
      final carMileage = _parseInt(
        firstRow[colIndex['car_mileage']!],
        'car_mileage',
      );
      final totalSpent = _parseInt(
        firstRow[colIndex['total_spent']!],
        'total_spent',
      );
      final lastOilChangeKm = _parseInt(
        firstRow[colIndex['last_oil_change_km']!],
        'last_oil_change_km',
      );

      final color = repos.carsRepo.colorId(colorName);

      repos.carsRepo.insertWithId(
        Car(
          id: carId,
          year: year,
          color: color,
          price: price,
          mileage: carMileage,
          make: make,
          model: model,
          plate: plate,
        ),
      );

      repos.carsRepo.saveCarStats(
        CarStats(
          carId: carId,
          totalSpent: totalSpent,
          lastOilChangeKm: lastOilChangeKm,
        ),
      );

      for (final row in entry.value) {
        final workIdStr = row[colIndex['work_id']!].toString();
        if (workIdStr.isEmpty) continue;

        final workId = _parseInt(row[colIndex['work_id']!], 'work_id');
        final dateStr = row[colIndex['work_date']!].toString();
        final categoryName = row[colIndex['work_category']!].toString();
        final workMileage = _parseInt(
          row[colIndex['work_mileage']!],
          'work_mileage',
        );
        final cost = _parseInt(row[colIndex['work_cost']!], 'work_cost');
        final description = row[colIndex['work_description']!].toString();

        final category = repos.carWorksRepo.categoryId(categoryName);
        final date = parseDateString(dateStr);

        repos.carWorksRepo.insertWithId(
          CarWork(
            id: workId,
            carId: carId,
            date: date,
            category: category,
            mileage: workMileage,
            cost: cost,
            description: description,
          ),
        );
      }
    }
  }

  static int _parseInt(dynamic value, String column, [int? row]) {
    final prefix = row != null ? 'Row ${row + 1}' : '';
    final hint = prefix.isNotEmpty ? '$prefix, ' : '';
    final str = value.toString().trim();
    final parsed = int.tryParse(str);
    if (parsed == null) {
      throw FormatException('${hint}Invalid integer for "$column": "$str"');
    }
    return parsed;
  }

  static void _validateRowLength(
    List<dynamic> row,
    int rowIndex,
    int expected,
  ) {
    if (row.length != expected) {
      throw FormatException(
        'Row ${rowIndex + 1}: expected $expected columns, got ${row.length}',
      );
    }
  }
}
