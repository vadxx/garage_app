// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'models/models.dart';

/// Approximate exchange rates: USD → target currency.
const _rates = {Currency.usd: 1.0, Currency.rub: 85.0, Currency.eur: 0.92};

/// Converts a USD-stored [value] to the target [currency] (rounded).
int usdToCurrency(int usdAmount, Currency currency) {
  final rate = _rates[currency] ?? 1.0;
  return (usdAmount * rate).round();
}

/// Converts a value in the given [currency] back to USD (rounded).
///
/// Use this before storing user input that was entered in a non-USD currency.
int currencyToUsd(int value, Currency currency) {
  final rate = _rates[currency] ?? 1.0;
  return (value / rate).round();
}

/// Returns the currency symbol for the given [currency].
String currencySymbol(Currency currency) => switch (currency) {
  Currency.usd => '\$',
  Currency.rub => '₽',
  Currency.eur => '€',
};

/// Formats a USD-stored [amount] in the user's preferred [currency].
///
/// Backend always stores values in USD. This converts for display only.
String formatCurrency(int usdAmount, Currency currency) {
  final converted = usdToCurrency(usdAmount, currency);
  return switch (currency) {
    Currency.usd => '\$$converted',
    Currency.rub => '$converted ₽',
    Currency.eur => '€$converted',
  };
}
