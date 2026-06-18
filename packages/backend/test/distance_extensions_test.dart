// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:backend/backend.dart';

void main() {
  group('distanceToUnit', () {
    test('km stays unchanged', () {
      expect(distanceToUnit(0, DistanceUnit.km), 0);
      expect(distanceToUnit(100, DistanceUnit.km), 100);
      expect(distanceToUnit(99999, DistanceUnit.km), 99999);
    });

    test('km to mi conversion', () {
      // 100 km ≈ 62.1 mi → rounds to 62
      expect(distanceToUnit(100, DistanceUnit.mi), 62);
      // 0 km = 0 mi
      expect(distanceToUnit(0, DistanceUnit.mi), 0);
      // 1 km ≈ 0.621 mi → rounds to 1
      expect(distanceToUnit(1, DistanceUnit.mi), 1);
      // 10 km ≈ 6.21 mi → rounds to 6
      expect(distanceToUnit(10, DistanceUnit.mi), 6);
      // 160 km ≈ 99.42 mi → rounds to 99
      expect(distanceToUnit(160, DistanceUnit.mi), 99);
      // 161 km ≈ 100.04 mi → rounds to 100
      expect(distanceToUnit(161, DistanceUnit.mi), 100);
    });

    test('rounding: 0.5 boundary for km to mi', () {
      // 1 km = 0.621... → rounds to 1
      expect(distanceToUnit(1, DistanceUnit.mi), 1);
      // 8 km = 4.97... → rounds to 5
      expect(distanceToUnit(8, DistanceUnit.mi), 5);
      // 9 km = 5.59... → rounds to 6
      expect(distanceToUnit(9, DistanceUnit.mi), 6);
    });
  });

  group('formatDistance', () {
    test('formats in km', () {
      expect(formatDistance(100, DistanceUnit.km), '100 km');
      expect(formatDistance(0, DistanceUnit.km), '0 km');
    });

    test('formats in mi', () {
      expect(formatDistance(100, DistanceUnit.mi), '62 mi');
      expect(formatDistance(0, DistanceUnit.mi), '0 mi');
    });
  });

  group('distanceUnitLabel', () {
    test('returns km', () {
      expect(distanceUnitLabel(DistanceUnit.km), 'km');
    });

    test('returns mi', () {
      expect(distanceUnitLabel(DistanceUnit.mi), 'mi');
    });
  });

  group('unitToKm', () {
    test('km stays unchanged', () {
      expect(unitToKm(0, DistanceUnit.km), 0);
      expect(unitToKm(100, DistanceUnit.km), 100);
      expect(unitToKm(99999, DistanceUnit.km), 99999);
    });

    test('mi to km conversion', () {
      // 62 mi ≈ 99.85 km → rounds to 100
      expect(unitToKm(62, DistanceUnit.km), 62);
      // 100 mi ≈ 160.93 km → rounds to 161
      expect(unitToKm(100, DistanceUnit.mi), 161);
      // 0 mi = 0 km
      expect(unitToKm(0, DistanceUnit.mi), 0);
      // 1 mi ≈ 1.609 km → rounds to 2
      expect(unitToKm(1, DistanceUnit.mi), 2);
    });

    test('round-trip: distanceToUnit then unitToKm', () {
      // 100 km → 62 mi → back to km should be close to 100
      final miles = distanceToUnit(100, DistanceUnit.mi);
      final backToKm = unitToKm(miles, DistanceUnit.mi);
      expect(backToKm, closeTo(100, 2));
    });
  });
}
