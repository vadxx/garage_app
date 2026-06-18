// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'models/models.dart';

const _kmToMi = 0.621371192;

/// Converts a KM [value] to [unit] and returns the rounded integer.
int distanceToUnit(int value, DistanceUnit unit) => switch (unit) {
  DistanceUnit.km => value,
  DistanceUnit.mi => (value * _kmToMi).round(),
};

/// Formats a KM [value] in [unit]: converted number + unit label.
String formatDistance(int value, DistanceUnit unit) {
  final converted = distanceToUnit(value, unit);
  final label = distanceUnitLabel(unit);
  return '$converted $label';
}

/// Converts a [value] from [unit] back to km (reverse of [distanceToUnit]).
int unitToKm(int value, DistanceUnit unit) => switch (unit) {
  DistanceUnit.km => value,
  DistanceUnit.mi => (value / _kmToMi).round(),
};

/// Returns the short label for a [DistanceUnit] ("km" or "mi").
String distanceUnitLabel(DistanceUnit unit) => switch (unit) {
  DistanceUnit.km => 'km',
  DistanceUnit.mi => 'mi',
};
