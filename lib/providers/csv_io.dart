// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backend/backend.dart' as backend;

import '../i18n/i18n.dart';
import 'cars_provider.dart';
import 'repositories_provider.dart';

Future<void> importCsv(BuildContext context, WidgetRef ref) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result == null || result.files.single.path == null) return;

  final file = File(result.files.single.path!);
  final csvContent = await file.readAsString();

  final repos = ref.read(repositoriesProvider).requireValue;

  try {
    backend.CsvService.importCsv(repos, csvContent);
    ref.invalidate(carsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.importSuccess)));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

Future<void> exportCsv(BuildContext context, WidgetRef ref) async {
  final repos = ref.read(repositoriesProvider).requireValue;
  final csvContent = backend.CsvService.exportCsv(repos);

  final result = await FilePicker.saveFile(
    dialogTitle: 'Export CSV',
    fileName: 'garage_export.csv',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result == null) return;

  try {
    final file = File(result);
    await file.writeAsString(csvContent);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.exportSuccess)));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
