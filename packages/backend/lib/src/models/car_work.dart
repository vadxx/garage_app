// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_work.freezed.dart';

enum Category {
  oil,
  fuel,
  cleaning,
  diagnostic,
  electronics,
  repair,
  replacement,
  parking,
  insurance,
  tiresWheels,
  taxFees,
}

@freezed
class CarWork with _$CarWork {
  const factory CarWork({
    required int id,
    required int carId,
    required int date, // since epoch
    required int category,
    required int mileage, // km
    required int cost, // usd
    required String description,
  }) = _CarWorks;

  static CarWork fromSqlRow(List<Object?> row) => CarWork(
    id: row[0] as int,
    carId: row[1] as int,
    date: row[2] as int,
    category: row[3] as int,
    mileage: row[4] as int,
    cost: row[5] as int,
    description: row[6] as String,
  );
}

extension CarWorkSql on CarWork {
  List<Object> toSqlRow() => [
    carId,
    date,
    category,
    mileage,
    cost,
    description,
  ];
}
