// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:backend/backend.dart';
import 'pages/pages.dart';

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
    GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
    GoRoute(path: Routes.addCar, builder: (_, _) => const AddEditCarPage()),
    GoRoute(
      path: Routes.editCarPattern,
      builder: (_, state) =>
          AddEditCarPage(carId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: Routes.carPattern,
      builder: (_, state) =>
          CarDetailPage(carId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

void goToSettings(BuildContext context) => context.go(Routes.settings);

void goToAddCar(BuildContext context) => context.go(Routes.addCar);
void goToEditCar(BuildContext context, int id) =>
    context.go(Routes.editCar(id));

void goToHome(BuildContext context) => context.go(Routes.home);
