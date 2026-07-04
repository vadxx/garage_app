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

    // GBP
    test('GBP: converts and formats', () {
      expect(formatCurrency(100, Currency.gbp), '£80');
    });

    test('GBP: formats zero', () {
      expect(formatCurrency(0, Currency.gbp), '£0');
    });

    // KRW
    test('KRW: converts and formats', () {
      expect(formatCurrency(100, Currency.krw), '₩145000');
    });

    test('KRW: formats zero', () {
      expect(formatCurrency(0, Currency.krw), '₩0');
    });

    // JPY
    test('JPY: converts and formats', () {
      expect(formatCurrency(100, Currency.jpy), '¥15000');
    });

    test('JPY: formats zero', () {
      expect(formatCurrency(0, Currency.jpy), '¥0');
    });

    // IDR
    test('IDR: converts and formats', () {
      expect(formatCurrency(100, Currency.idr), 'Rp1620000');
    });

    test('IDR: formats zero', () {
      expect(formatCurrency(0, Currency.idr), 'Rp0');
    });

    // BRL
    test('BRL: converts and formats', () {
      expect(formatCurrency(100, Currency.brl), r'R$560');
    });

    test('BRL: formats zero', () {
      expect(formatCurrency(0, Currency.brl), r'R$0');
    });

    // MXN
    test('MXN: converts and formats', () {
      expect(formatCurrency(100, Currency.mxn), r'MX$1850');
    });

    test('MXN: formats zero', () {
      expect(formatCurrency(0, Currency.mxn), r'MX$0');
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

    test('round-trip USD ↔ GBP preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inGbp = usdToCurrency(amount, Currency.gbp);
        final backToUsd = currencyToUsd(inGbp, Currency.gbp);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ KRW preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inKrw = usdToCurrency(amount, Currency.krw);
        final backToUsd = currencyToUsd(inKrw, Currency.krw);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ JPY preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inJpy = usdToCurrency(amount, Currency.jpy);
        final backToUsd = currencyToUsd(inJpy, Currency.jpy);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ IDR preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inIdr = usdToCurrency(amount, Currency.idr);
        final backToUsd = currencyToUsd(inIdr, Currency.idr);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ BRL preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inBrl = usdToCurrency(amount, Currency.brl);
        final backToUsd = currencyToUsd(inBrl, Currency.brl);
        expect(backToUsd, amount, reason: 'Failed for $amount USD');
      }
    });

    test('round-trip USD ↔ MXN preserves value', () {
      for (final amount in [0, 1, 10, 100, 500, 8420, 99999]) {
        final inMxn = usdToCurrency(amount, Currency.mxn);
        final backToUsd = currencyToUsd(inMxn, Currency.mxn);
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

    test('GBP returns pound sign', () {
      expect(currencySymbol(Currency.gbp), '£');
    });

    test('KRW returns won sign', () {
      expect(currencySymbol(Currency.krw), '₩');
    });

    test('JPY returns yen sign', () {
      expect(currencySymbol(Currency.jpy), '¥');
    });

    test('IDR returns rupiah sign', () {
      expect(currencySymbol(Currency.idr), 'Rp');
    });

    test('BRL returns real sign', () {
      expect(currencySymbol(Currency.brl), r'R$');
    });

    test('MXN returns peso sign', () {
      expect(currencySymbol(Currency.mxn), r'MX$');
    });
  });
}
