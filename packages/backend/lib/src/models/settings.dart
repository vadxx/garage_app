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

  static AppSettings fromSqlRow(List<Object?> row) => AppSettings(
    language: Language.values[row[0] as int], // skip id[0]
    distanceUnit: DistanceUnit.values[row[1] as int],
    theme: Theme.values[row[2] as int],
    currency: Currency.values[row[3] as int],
  );
}

extension AppSettingsSql on AppSettings {
  List<int> toSqlRow() => [
    language.index,
    distanceUnit.index,
    theme.index,
    currency.index,
  ];
}
