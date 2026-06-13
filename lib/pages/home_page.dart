// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../i18n/i18n.dart';

import '../providers/providers.dart';

const _bigTextSize = TextStyle(fontSize: 20);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.t.appTitle;
    final settingsButton = TextButton.icon(
      onPressed: () => goToSettings(context),
      label: Text('⚙️', style: _bigTextSize),
    );
    final addCarButton = TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => goToAddCar(context),
      icon: Text('➕', style: _bigTextSize),
      label: Text(context.t.addCar, style: _bigTextSize),
    );
    return Scaffold(
      appBar: AppBar(
        leading: Center(child: Text('🚗', style: _bigTextSize)),
        title: Text(title),
        titleSpacing: 0, // Drop the gap btw the leading and title
        actions: [settingsButton],
      ),
      body: const _CarsList(),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: 64,
        child: Padding(padding: const EdgeInsets.all(4.0), child: addCarButton),
      ),
    );
  }
}

class _CarsList extends ConsumerWidget {
  const _CarsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (_, i) => ListTile(
        title: Text('${cars[i].make} ${cars[i].model}'),
        subtitle: Text('${cars[i].year} · ${cars[i].plate}'),
        onTap: () => goToCarDetail(context, cars[i].id),
      ),
    );
  }
}
