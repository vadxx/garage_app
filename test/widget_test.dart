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
}
