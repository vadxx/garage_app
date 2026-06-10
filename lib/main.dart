// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:backend/backend.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final awesome = Awesome();
    if (!awesome.isAwesome) {
      return Container();
    }
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
