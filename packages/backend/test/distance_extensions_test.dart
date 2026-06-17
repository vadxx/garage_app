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
}
