// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:backend/backend.dart' as backend;

const bigTextSize = TextStyle(fontSize: 18);

const carColorPalette = [
  (backend.CarColor.white, Colors.white),
  (backend.CarColor.black, Colors.black),
  (backend.CarColor.silver, Colors.grey),
  (backend.CarColor.blue, Colors.blue),
  (backend.CarColor.red, Colors.red),
  (backend.CarColor.green, Colors.green),
  (backend.CarColor.yellow, Colors.yellow),
  (backend.CarColor.orange, Colors.orange),
  (backend.CarColor.purple, Colors.purple),
  (backend.CarColor.brown, Colors.brown),
];

class CircleColor extends StatelessWidget {
  const CircleColor({
    super.key,
    required this.color,
    required this.selected,
    this.width,
    this.height,
  });

  final Color color;
  final bool selected;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final border = BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? Colors.blue : Colors.grey.shade400,
        width: selected ? 3 : 1,
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        width: width ?? 40,
        height: height ?? 40,
        decoration: border,
      ),
    );
  }
}

class Field extends StatelessWidget {
  final String label;
  final String? error;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const Field({
    super.key,
    required this.label,
    this.error,
    this.keyboardType,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}
