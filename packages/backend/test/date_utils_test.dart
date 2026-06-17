// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:backend/backend.dart';

void main() {
  group('parseDateString', () {
    test('parses YYYY-MM-DD', () {
      final epoch = parseDateString('2024-06-15');
      expect(formatEpochDate(epoch), '2024-06-15');
    });

    test('parses YYYY-M-D (single-digit month/day)', () {
      final epoch = parseDateString('2024-6-5');
      expect(formatEpochDate(epoch), '2024-06-05');
    });

    test('parses leap year 2024-02-29', () {
      final epoch = parseDateString('2024-02-29');
      expect(formatEpochDate(epoch), '2024-02-29');
    });

    test('trims leading whitespace', () {
      final epoch = parseDateString('  2024-06-15');
      expect(formatEpochDate(epoch), '2024-06-15');
    });

    test('trims trailing whitespace', () {
      final epoch = parseDateString('2024-06-15  ');
      expect(formatEpochDate(epoch), '2024-06-15');
    });

    test('throws for non-leap year Feb 29', () {
      expect(() => parseDateString('2023-02-29'), throwsFormatException);
    });

    test('throws for month 13', () {
      expect(() => parseDateString('2024-13-01'), throwsFormatException);
    });

    test('throws for day 32', () {
      expect(() => parseDateString('2024-01-32'), throwsFormatException);
    });

    test('throws for slash separator (YYYY/MM/DD)', () {
      expect(() => parseDateString('2024/06/15'), throwsFormatException);
    });

    test('throws for dot separator (YYYY.MM.DD)', () {
      expect(() => parseDateString('2024.06.15'), throwsFormatException);
    });

    test('throws for EU DD-MM-YYYY', () {
      expect(() => parseDateString('15-06-2024'), throwsFormatException);
    });

    test('throws for US MM/DD/YYYY', () {
      expect(() => parseDateString('06/15/2024'), throwsFormatException);
    });

    test('throws for EU DD.MM.YYYY', () {
      expect(() => parseDateString('15.06.2024'), throwsFormatException);
    });

    test('throws for garbage string', () {
      expect(() => parseDateString('not-a-date'), throwsFormatException);
    });

    test('throws for empty string', () {
      expect(() => parseDateString(''), throwsFormatException);
    });

    test('throws for mixed separators', () {
      expect(() => parseDateString('2024-06/15'), throwsFormatException);
    });
  });
}
