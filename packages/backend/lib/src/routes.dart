// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

class Routes {
  static const home = '/';
  static const settings = '/settings';

  static const addCar = '/add_car';

  /// Route pattern for GoRouter definition (uses :param syntax)
  static const editCarPattern = '/edit_car/:id';
  static String editCar(int id) => '/edit_car/$id';

  static const carPattern = '/cars/:id';

  /// Actual path for navigation (fills in the value)
  static String car(String id) => '/cars/$id';

  static String addCarWorkPattern = '$carPattern/add_work';
  static String addCarWork(String carId) => '${car(carId)}/add_work';
}