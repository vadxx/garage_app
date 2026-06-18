// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  final reposAsync = ref.read(repositoriesProvider);
  assert(
    reposAsync.hasValue,
    'repositoriesProvider must resolve before importCsv can access it',
  );
  final repos = reposAsync.requireValue;

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
  final reposAsync = ref.read(repositoriesProvider);
  assert(
    reposAsync.hasValue,
    'repositoriesProvider must resolve before exportCsv can access it',
  );
  final repos = reposAsync.requireValue;
  final csvContent = backend.CsvService.exportCsv(repos);
  final bytes = Uint8List.fromList(utf8.encode(csvContent));

  final result = await FilePicker.saveFile(
    dialogTitle: 'Export CSV',
    fileName: 'garage_export.csv',
    bytes: bytes,
  );
  if (result == null) return;

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.t.exportSuccess)));
  }
}
