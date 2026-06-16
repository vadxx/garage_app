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
    GoRoute(
      path: Routes.addCarWorkPattern,
      builder: (_, state) =>
          AddEditCarWorkPage(carId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: Routes.editCarWorkPattern,
      builder: (_, state) => AddEditCarWorkPage(
        carId: int.parse(state.pathParameters['id']!),
        workId: int.parse(state.pathParameters['workId']!),
      ),
    ),
  ],
);

void goToSettings(BuildContext context) => context.go(Routes.settings);

void goToCarDetail(BuildContext context, int id) =>
    context.go(Routes.car(id.toString()));

void goToAddCar(BuildContext context) => context.go(Routes.addCar);
void goToEditCar(BuildContext context, int id) =>
    context.go(Routes.editCar(id));

void goToHome(BuildContext context) => context.go(Routes.home);

void goToAddCarWork(BuildContext context, int carId) =>
    context.go(Routes.addCarWork(carId.toString()));

void goToEditCarWork(BuildContext context, int carId, int workId) =>
    context.go(Routes.editCarWork(carId.toString(), workId));
