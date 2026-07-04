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

    final de = await AppLocale.de.build();
    expect(de.appTitle, 'Garage');

    final es = await AppLocale.es.build();
    expect(es.appTitle, 'Garaje');

    final fr = await AppLocale.fr.build();
    expect(fr.appTitle, 'Garage');
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

    final de = await AppLocale.de.build();
    expect(de.oilChangeDataNotProvided, contains('Ölwechsel'));
    expect(de.errorLoadingStats, 'Fehler beim Laden der Statistiken');
    expect(de.error, 'Fehler');
    expect(de.initFailed, 'Initialisierung fehlgeschlagen');
    expect(de.distanceUnit, 'Entfernungseinheit');

    final es = await AppLocale.es.build();
    expect(es.oilChangeDataNotProvided, contains('Cambio de aceite'));
    expect(es.errorLoadingStats, 'Error al cargar estadísticas');
    expect(es.error, 'Error');
    expect(es.initFailed, 'Error de inicio');
    expect(es.distanceUnit, 'Unidad de distancia');

    final fr = await AppLocale.fr.build();
    expect(fr.oilChangeDataNotProvided, contains('Vidange'));
    expect(fr.errorLoadingStats, 'Erreur lors du chargement des statistiques');
    expect(fr.error, 'Erreur');
    expect(fr.initFailed, 'Échec de l\'initialisation');
    expect(fr.distanceUnit, 'Unité de distance');
  });
}
