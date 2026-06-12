// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:freezed_annotation/freezed_annotation.dart';

part 'car.freezed.dart';

@freezed
class Car with _$Car {
  const factory Car({
    required int id,
    required int year,
    required int color,
    required int price,
    required int mileage,
    required String make,
    required String model,
    required String plate,
  }) = _Car;

  static Car fromSqlRow(List<Object?> row) => Car(
    id: row[0] as int,
    year: row[1] as int,
    color: row[2] as int,
    price: row[3] as int,
    mileage: row[4] as int,
    make: row[5] as String,
    model: row[6] as String,
    plate: row[7] as String,
  );
}

extension CarSql on Car {
  List<Object> toSqlRow() => [year, color, price, mileage, make, model, plate];
}
