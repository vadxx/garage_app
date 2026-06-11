// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

enum Language { en, ru }

enum DistanceUnit { km, mi }

enum Theme { system, light, dark }

enum Currency { usd, rub, eur }

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(Language.en) Language language,
    @Default(DistanceUnit.km) DistanceUnit distanceUnit,
    @Default(Theme.system) Theme theme,
    @Default(Currency.usd) Currency currency,
  }) = _AppSettings;

  factory AppSettings.fromRow(Map<String, dynamic> row) => AppSettings(
    language: Language.values[row['language'] as int],
    distanceUnit: DistanceUnit.values[row['distance_unit'] as int],
    theme: Theme.values[row['theme'] as int],
    currency: Currency.values[row['currency'] as int],
  );
}

extension AppSettingsRow on AppSettings {
  Map<String, int> toRow() => {
    'language': language.index,
    'distance_unit': distanceUnit.index,
    'theme': theme.index,
    'currency': currency.index,
  };
}
