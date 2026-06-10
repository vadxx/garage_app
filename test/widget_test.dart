// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

// import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:garage_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that our counter starts at 0.
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
