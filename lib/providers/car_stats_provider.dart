// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';
import 'repositories_provider.dart';

final carStatsProvider = FutureProvider.family<CarStats, int>((ref, carId) {
  return ref.read(carsRepositoryProvider).loadCarStats(carId);
});
