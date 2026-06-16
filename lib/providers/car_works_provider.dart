// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart';
import 'repositories_provider.dart';

final carWorksProvider = FutureProvider.family<List<CarWork>, int>((
  ref,
  carId,
) {
  return ref.read(carWorksRepositoryProvider).loadByCarId(carId);
});
