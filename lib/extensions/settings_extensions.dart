// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:backend/backend.dart' as backend;

import '../i18n/i18n.dart';

extension LanguageX on backend.Language {
  Locale get locale => Locale(name);

  AppLocale get appLocale => switch (this) {
    backend.Language.en => AppLocale.en,
    backend.Language.ru => AppLocale.ru,
    backend.Language.de => AppLocale.de,
  };
}

extension ThemeX on backend.Theme {
  ThemeMode get mode => switch (this) {
    backend.Theme.light => ThemeMode.light,
    backend.Theme.system => ThemeMode.system,
    backend.Theme.dark => ThemeMode.dark,
  };
}
