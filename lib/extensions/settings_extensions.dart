// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:backend/backend.dart' as backend;

extension LanguageX on backend.Language {
  Locale get locale => Locale(name);
}

extension ThemeX on backend.Theme {
  ThemeMode get mode => switch (this) {
    backend.Theme.light => ThemeMode.light,
    backend.Theme.system => ThemeMode.system,
    backend.Theme.dark => ThemeMode.dark,
  };
}