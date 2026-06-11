// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';

import 'repositories_provider.dart';

final appSettingsProvider = Provider<AppSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.load();
});
