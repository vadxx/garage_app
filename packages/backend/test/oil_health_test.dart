// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:backend/backend.dart';

void main() {
  group('oilHealth', () {
    test('returns 100% when no oil change data (lastOilChangeKm < 0)', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: -1);
      final result = oilHealth(stats, 50000);
      expect(result.kmSince, 0);
      expect(result.healthPercent, 100);
    });

    test('calculates km since last oil change', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 40000);
      final result = oilHealth(stats, 50000);
      expect(result.kmSince, 10000);
    });

    test('health is 0% when interval is fully consumed', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 40000);
      final result = oilHealth(stats, 50000, intervalKm: 10000);
      expect(result.healthPercent, 0);
    });

    test('health is 50% at halfway point', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 45000);
      final result = oilHealth(stats, 50000, intervalKm: 10000);
      expect(result.healthPercent, 50);
    });

    test('health is clamped to 0 when over interval', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 30000);
      // 20000 km over 10000 interval → negative health → clamped to 0
      final result = oilHealth(stats, 50000, intervalKm: 10000);
      expect(result.healthPercent, 0);
    });

    test('health is 100% at 0 km since change', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 50000);
      final result = oilHealth(stats, 50000, intervalKm: 10000);
      expect(result.kmSince, 0);
      expect(result.healthPercent, 100);
    });

    test('custom interval affects health calculation', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 40000);
      // 10000 km over 20000 interval → 50%
      final result = oilHealth(stats, 50000, intervalKm: 20000);
      expect(result.healthPercent, 50);
    });

    test('kmSince is clamped to 0 when currentMileage < lastOilChangeKm', () {
      final stats = CarStats(carId: 1, totalSpent: 0, lastOilChangeKm: 60000);
      // currentMileage < lastOilChangeKm → clamp to 0
      final result = oilHealth(stats, 50000);
      expect(result.kmSince, 0);
    });
  });
}
