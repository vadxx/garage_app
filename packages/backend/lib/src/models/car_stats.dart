// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_stats.freezed.dart';

@freezed
class CarStats with _$CarStats {
  const factory CarStats({
    required int carId,
    required int totalSpent,
    required int lastOilChangeKm, // mileage
  }) = _CarStats;

  static CarStats fromSqlRow(List<Object?> row) => CarStats(
    carId: row[0] as int,
    totalSpent: row[1] as int,
    lastOilChangeKm: row[2] as int,
  );
}

extension CarStatsSql on CarStats {
  List<Object> toSqlRow() => [carId, totalSpent, lastOilChangeKm];
}
