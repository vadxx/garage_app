// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:backend/backend.dart' as backend;
import 'package:garage_app/app_router.dart';
import 'package:garage_app/i18n/i18n.dart';
import 'package:garage_app/providers/providers.dart';

import 'package:backend/testing.dart';

final GlobalKey _boundaryKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocaleSync(AppLocale.en);

  final carsRepo = FakeCarsRepository();
  final worksRepo = FakeCarWorksRepository();
  final settingsRepo = FakeSettingsRepository()
    ..save(
      const backend.AppSettings(
        language: backend.Language.en,
        distanceUnit: backend.DistanceUnit.km,
        theme: backend.Theme.light,
        currency: backend.Currency.usd,
        oilIntervalKm: 10000,
      ),
    );

  final repos = _FakeRepositories(
    carsRepo: carsRepo,
    carWorksRepo: worksRepo,
    settingsRepo: settingsRepo,
  );

  final csvFile = File('datasets/demo_dataset.csv');
  final csvContent = await csvFile.readAsString();
  backend.CsvService.importCsv(repos, csvContent);

  runApp(
    ProviderScope(
      overrides: [
        carsRepositoryProvider.overrideWith((ref) => carsRepo),
        carWorksRepositoryProvider.overrideWith((ref) => worksRepo),
        settingsRepositoryProvider.overrideWith((ref) => settingsRepo),
      ],
      child: TranslationProvider(child: const ScreenshotApp()),
    ),
  );
}

class _FakeRepositories implements backend.Repositories {
  _FakeRepositories({
    required this.carsRepo,
    required this.carWorksRepo,
    required this.settingsRepo,
  });

  @override
  final backend.CarsRepository carsRepo;

  @override
  final backend.CarWorksRepository carWorksRepo;

  @override
  final backend.SettingsRepository settingsRepo;

  @override
  void init(String appStoragePath) {}

  @override
  void clearAll() {
    for (final car in carsRepo.load()) {
      carsRepo.delete(car.id);
    }
  }

  @override
  void transaction(void Function() action) => action();
}

class ScreenshotApp extends StatefulWidget {
  const ScreenshotApp({super.key});

  @override
  State<ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends State<ScreenshotApp> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await WidgetsBinding.instance.endOfFrame;

    await _capture('home');

    appRouter.go(backend.Routes.settings);
    await _capture('settings');

    appRouter.go(backend.Routes.home);
    await WidgetsBinding.instance.endOfFrame;
    appRouter.go(backend.Routes.car('1'));
    await _capture('car_detail');

    appRouter.go(backend.Routes.addCarWork('1'));
    await _capture('add_car_work');

    appRouter.go(backend.Routes.home);
    await WidgetsBinding.instance.endOfFrame;
    appRouter.go(backend.Routes.addCar);
    await _capture('add_car');

    await exit(0);
  }

  Future<void> _capture(String name) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        _boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = Directory('screenshots');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    await File('screenshots/$name.png').writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp.router(
        locale: AppLocale.en.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: appRouter,
        theme: ThemeData(brightness: Brightness.light),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
