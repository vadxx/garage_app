// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';
import 'package:path_provider/path_provider.dart';
import 'package:backend/sqlite_backend.dart'; // Should be called only here

import 'package:path/path.dart' as p;

const String _appName = "garage_app";

final repositoriesProvider = FutureProvider<Repositories>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final appDir = p.join(dir.path, _appName);
  return SqliteRepositories()..init(appDir);
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(repositoriesProvider).requireValue.settingsRepo,
);
