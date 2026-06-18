// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_test/flutter_test.dart';

import 'package:garage_app/i18n/i18n.dart';

void main() {
  test('appTitle translations', () async {
    final en = AppLocale.en.buildSync();
    expect(en.appTitle, 'Garage');

    final ru = await AppLocale.ru.build();
    expect(ru.appTitle, 'Гараж');
  });

  test('new translation keys exist', () async {
    final en = AppLocale.en.buildSync();
    expect(en.oilChangeDataNotProvided, contains('Oil change'));
    expect(en.errorLoadingStats, 'Error loading stats');
    expect(en.error, 'Error');
    expect(en.initFailed, 'Init failed');
    expect(en.distanceUnit, 'Distance unit');

    final ru = await AppLocale.ru.build();
    expect(ru.oilChangeDataNotProvided, contains('замене масла'));
    expect(ru.errorLoadingStats, 'Ошибка загрузки статистики');
    expect(ru.error, 'Ошибка');
    expect(ru.initFailed, 'Ошибка инициализации');
    expect(ru.distanceUnit, 'Единица расстояния');
  });
}
