// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

export 'settings_page.dart';

import 'package:flutter/material.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

const _bigTextSize = TextStyle(fontSize: 24);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.t.appTitle;
    return Scaffold(
      appBar: AppBar(
        leading: Center(child: Text('🚗', style: _bigTextSize)),
        title: Text(title),
        titleSpacing: 0, // Drop the gap btw the leading and title
        actions: [
          TextButton.icon(
            onPressed: () => goToSettings(context),
            label: Text('⚙️', style: _bigTextSize),
          ),
        ],
      ),
    );
  }
}

class CarDetailPage extends StatelessWidget {
  const CarDetailPage({super.key, required this.carId});

  final int carId;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
