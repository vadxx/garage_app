// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

export 'settings_page.dart';
export 'home_page.dart';
export 'add_edit_car_page.dart';

import 'package:flutter/material.dart';

class CarDetailPage extends StatelessWidget {
  const CarDetailPage({super.key, required this.carId});

  final int carId;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
