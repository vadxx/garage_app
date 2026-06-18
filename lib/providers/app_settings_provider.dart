// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';

import 'repositories_provider.dart';

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  void setLanguage(Language v) {
    state = state.copyWith(language: v);
    _save();
  }

  void setDistanceUnit(DistanceUnit v) {
    state = state.copyWith(distanceUnit: v);
    _save();
  }

  void setTheme(Theme v) {
    state = state.copyWith(theme: v);
    _save();
  }

  void setCurrency(Currency v) {
    state = state.copyWith(currency: v);
    _save();
  }

  void setOilIntervalKm(int v) {
    state = state.copyWith(oilIntervalKm: v);
    _save();
  }

  void _save() => ref.read(settingsRepositoryProvider).save(state);
}
