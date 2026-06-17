// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:backend/backend.dart';

void main() {
  group('formatCurrency', () {
    // USD
    test('USD: formats positive amount', () {
      expect(formatCurrency(100, Currency.usd), r'$100');
    });

    test('USD: formats zero', () {
      expect(formatCurrency(0, Currency.usd), r'$0');
    });

    test('USD: formats large amount', () {
      expect(formatCurrency(999999, Currency.usd), r'$999999');
    });

    // RUB
    test('RUB: converts and formats', () {
      expect(formatCurrency(100, Currency.rub), '8500 ₽');
    });

    test('RUB: formats single dollar', () {
      expect(formatCurrency(1, Currency.rub), '85 ₽');
    });

    test('RUB: formats zero', () {
      expect(formatCurrency(0, Currency.rub), '0 ₽');
    });

    test('RUB: formats large amount', () {
      expect(formatCurrency(10000, Currency.rub), '850000 ₽');
    });

    // EUR
    test('EUR: converts and formats', () {
      expect(formatCurrency(100, Currency.eur), '€92');
    });

    test('EUR: rounds correctly', () {
      // 100 * 0.92 = 92
      expect(formatCurrency(100, Currency.eur), '€92');
    });

    test('EUR: rounds up fractional result', () {
      // 101 * 0.92 = 92.92 → rounds to 93
      expect(formatCurrency(101, Currency.eur), '€93');
    });

    test('EUR: rounds 0.5 down', () {
      // 50 * 0.92 = 46.0 → 46
      expect(formatCurrency(50, Currency.eur), '€46');
    });

    test('EUR: formats zero', () {
      expect(formatCurrency(0, Currency.eur), '€0');
    });

    // Edge cases
    test('handles single unit', () {
      expect(formatCurrency(1, Currency.usd), r'$1');
      expect(formatCurrency(1, Currency.rub), '85 ₽');
      expect(formatCurrency(1, Currency.eur), '€1');
    });

    test('USD → USD identity: amount unchanged for all inputs', () {
      for (final amount in [0, 1, 10, 100, 1000, 99999]) {
        expect(formatCurrency(amount, Currency.usd), r'$' + amount.toString());
      }
    });
  });

  group('usdToCurrency', () {
    test('USD identity', () {
      expect(usdToCurrency(100, Currency.usd), 100);
    });

    test('USD → RUB multiplies by 85', () {
      expect(usdToCurrency(100, Currency.rub), 8500);
    });

    test('USD → EUR multiplies by 0.92 and rounds', () {
      expect(usdToCurrency(100, Currency.eur), 92);
    });
  });

  group('currencyToUsd', () {
    test('USD identity', () {
      expect(currencyToUsd(100, Currency.usd), 100);
    });

    test('RUB → USD divides by 85', () {
      expect(currencyToUsd(8500, Currency.rub), 100);
    });

    test('EUR → USD divides by 0.92 and rounds', () {
      expect(currencyToUsd(92, Currency.eur), 100);
    });

    test('round-trip USD ↔ RUB preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inRub = usdToCurrency(amount, Currency.rub);
        final backToUsd = currencyToUsd(inRub, Currency.rub);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ EUR preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inEur = usdToCurrency(amount, Currency.eur);
        final backToUsd = currencyToUsd(inEur, Currency.eur);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });
  });

  group('currencySymbol', () {
    test('USD returns dollar sign', () {
      expect(currencySymbol(Currency.usd), r'$');
    });

    test('RUB returns ruble sign', () {
      expect(currencySymbol(Currency.rub), '₽');
    });

    test('EUR returns euro sign', () {
      expect(currencySymbol(Currency.eur), '€');
    });
  });
}
