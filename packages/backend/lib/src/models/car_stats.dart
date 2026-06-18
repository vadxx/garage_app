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
    @Default(-1) int topCategory,
  }) = _CarStats;

  static CarStats fromSqlRow(List<Object?> row) => CarStats(
    carId: row[0] as int,
    totalSpent: row[1] as int,
    lastOilChangeKm: row[2] as int,
    topCategory: row.length > 3 ? row[3] as int : -1,
  );
}

extension CarStatsSql on CarStats {
  List<Object> toSqlRow() => [carId, totalSpent, lastOilChangeKm, topCategory];
}

/// Oil health data based on configurable interval (default 10,000 km).
/// Returns km driven since last oil change and health percent (0–100).
/// Health is 100 when no oil change data ([lastOilChangeKm] < 0).
({int kmSince, int healthPercent}) oilHealth(
  CarStats stats,
  int currentMileage, {
  int intervalKm = 10000,
}) {
  if (stats.lastOilChangeKm < 0) return (kmSince: 0, healthPercent: 100);
  final kmSince = (currentMileage - stats.lastOilChangeKm).clamp(
    0,
    currentMileage,
  );
  final healthPercent = ((1 - kmSince / intervalKm) * 100)
      .clamp(0, 100)
      .toInt();
  return (kmSince: kmSince, healthPercent: healthPercent);
}
