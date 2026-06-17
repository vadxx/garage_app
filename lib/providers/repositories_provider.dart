// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:backend/sqlite_backend.dart'; // Should be called only here

import 'package:path/path.dart' as p;

const String _appName = "garage_app";

final repositoriesProvider = FutureProvider<Repositories>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final appDir = p.join(dir.path, _appName);
  await Directory(appDir).create(recursive: true);
  return SqliteRepositories()..init(appDir);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final repos = ref.watch(repositoriesProvider);
  assert(
    repos.hasValue,
    'repositoriesProvider must resolve before settingsRepositoryProvider can be accessed',
  );
  return repos.requireValue.settingsRepo;
});

final carsRepositoryProvider = Provider<CarsRepository>((ref) {
  final repos = ref.watch(repositoriesProvider);
  assert(
    repos.hasValue,
    'repositoriesProvider must resolve before carsRepositoryProvider can be accessed',
  );
  return repos.requireValue.carsRepo;
});

final carWorksRepositoryProvider = Provider<CarWorksRepository>((ref) {
  final repos = ref.watch(repositoriesProvider);
  assert(
    repos.hasValue,
    'repositoriesProvider must resolve before carWorksRepositoryProvider can be accessed',
  );
  return repos.requireValue.carWorksRepo;
});
