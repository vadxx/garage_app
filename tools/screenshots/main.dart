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

import 'package:garage_app/pages/stats_bottom_sheets.dart';
import 'package:garage_app/providers/providers.dart';

import 'package:backend/testing.dart';

final GlobalKey _boundaryKey = GlobalKey();

/// Screenshot device profile.
class DeviceProfile {
  final String name;
  final double width;
  final double height;
  final double pixelRatio;
  final String outputDir;
  final bool supportsFraming;

  const DeviceProfile({
    required this.name,
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.outputDir,
    this.supportsFraming = false,
  });

  double get physicalWidth => width * pixelRatio;
  double get physicalHeight => height * pixelRatio;
}

/// Phone profile: FHD portrait, 1080x1920.
const phoneProfile = DeviceProfile(
  name: 'phone',
  width: 360,
  height: 640,
  pixelRatio: 3.0,
  outputDir: 'screenshots',
  supportsFraming: true,
);

/// 7-inch tablet profile: 1200x1920.
const tablet7Profile = DeviceProfile(
  name: 'tablet_7',
  width: 600,
  height: 960,
  pixelRatio: 2.0,
  outputDir: 'screenshots/tablet_7inch',
);

/// 10-inch tablet profile: 1600x2560.
const tablet10Profile = DeviceProfile(
  name: 'tablet_10',
  width: 800,
  height: 1280,
  pixelRatio: 2.0,
  outputDir: 'screenshots/tablet_10inch',
);

const _deviceProfiles = <String, DeviceProfile>{
  'phone': phoneProfile,
  'tablet_7': tablet7Profile,
  'tablet_10': tablet10Profile,
};

/// Promo-frame canvas size.
const double framedCanvasWidth = 1200;
const double framedCanvasHeight = 2400;

/// Pixel-style frame geometry.
const double frameBezel = 12;
const double frameTopMargin = 450; // lowers the phone for top promo text
const double bodyCornerRadius = 42;
const double screenCornerRadius = 30;

/// Promo text shown above each framed screenshot.
final _promoTexts = <String, ({String title, String subtitle})>{
  'home': (
    title: 'All your cars\nin one place',
    subtitle: 'Track mileage, value & spending.',
  ),
  'settings': (
    title: 'Make it yours',
    subtitle: 'Currency, units, language & oil interval.',
  ),
  'car_detail': (
    title: 'Every service\nrecorded',
    subtitle: 'Full history and stats.',
  ),
  'oil_health': (
    title: 'Oil health, tracked',
    subtitle: 'Know when your next oil change is due.',
  ),
  'category_stats': (
    title: 'See where the\nmoney goes',
    subtitle: 'Spending by category.',
  ),
  'add_car_work': (
    title: 'Log work in\nseconds',
    subtitle: 'Log category, date, price & mileage.',
  ),
  'add_car': (
    title: 'Add a new\ncar easily',
    subtitle: 'Color, specs and mileage.',
  ),
};

DeviceProfile _parseDeviceProfile(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--device=')) {
      final name = arg.substring('--device='.length);
      final profile = _deviceProfiles[name];
      if (profile != null) return profile;
      throw ArgumentError('Unknown device profile: $name');
    }
  }
  return phoneProfile;
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocaleSync(AppLocale.en);

  final profile = _parseDeviceProfile(args);
  final framed = args.contains('--framed') && profile.supportsFraming;

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
      child: TranslationProvider(
        child: ScreenshotApp(profile: profile, framed: framed),
      ),
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

class ScreenshotApp extends ConsumerStatefulWidget {
  const ScreenshotApp({required this.profile, required this.framed, super.key});

  final DeviceProfile profile;
  final bool framed;

  @override
  ConsumerState<ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends ConsumerState<ScreenshotApp> {
  late final Color _themeColor;

  @override
  void initState() {
    super.initState();
    _themeColor = ThemeData(brightness: Brightness.light).colorScheme.primary;
    _run();
  }

  void _showOilHistoryBottomSheet() {
    final context = appNavigatorKey.currentContext!;
    showOilHistoryBottomSheet(context, ref, 1);
  }

  void _showCategoryRatingsBottomSheet() {
    final context = appNavigatorKey.currentContext!;
    showCategoryRatingsBottomSheet(context, ref, 1);
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

    _showOilHistoryBottomSheet();
    await _capture('oil_health');

    _showCategoryRatingsBottomSheet();
    await _capture('category_stats');

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

    final rawBoundary =
        _boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final rawImage = await rawBoundary.toImage(
      pixelRatio: widget.profile.pixelRatio,
    );
    final rawByteData = await rawImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final rawBytes = rawByteData!.buffer.asUint8List();

    final dir = Directory(widget.profile.outputDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    await File('${widget.profile.outputDir}/$name.png').writeAsBytes(rawBytes);

    if (widget.framed) {
      final framedImage = await _composeFramedImage(
        rawImage,
        _themeColor,
        name,
        widget.profile,
      );
      final framedByteData = await framedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final framedBytes = framedByteData!.buffer.asUint8List();

      final framedDir = Directory('screenshots/framed');
      if (!framedDir.existsSync()) framedDir.createSync(recursive: true);
      await File('screenshots/framed/$name.png').writeAsBytes(framedBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child!,
      ),
    );

    return Center(
      child: SizedBox(
        width: widget.profile.width,
        height: widget.profile.height,
        child: RepaintBoundary(key: _boundaryKey, child: app),
      ),
    );
  }
}

/// Builds a centered paragraph for drawing promo text onto the canvas.
ui.Paragraph _buildParagraph(
  String text,
  double fontSize,
  ui.FontWeight weight,
  double maxWidth, {
  ui.Color color = const ui.Color(0xFFFFFFFF),
  ui.FontStyle? fontStyle,
}) {
  final builder =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textAlign: ui.TextAlign.center,
            textDirection: ui.TextDirection.ltr,
          ),
        )
        ..pushStyle(
          ui.TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: weight,
            fontStyle: fontStyle,
            shadows: const [
              ui.Shadow(
                color: ui.Color(0x4D000000),
                blurRadius: 5,
                offset: ui.Offset(0, 1),
              ),
            ],
          ),
        )
        ..addText(text);
  final paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
  return paragraph;
}

/// Composes a 1200x2400 promo screenshot by drawing [rawImage] inside a
/// Pixel-style phone frame on a vertically expanded gradient background that
/// matches [themeColor], with per-screen promo text at the top.
Future<ui.Image> _composeFramedImage(
  ui.Image rawImage,
  Color themeColor,
  String name,
  DeviceProfile profile,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, framedCanvasWidth, framedCanvasHeight),
  );

  // Expanded vertical gradient: saturated theme color at the top (where the
  // promo text will sit) fading to a lighter tint at the bottom.
  final gradientStart = Color.lerp(themeColor, Colors.white, 0.15)!;
  final gradientEnd = Color.lerp(themeColor, Colors.white, 0.75)!;
  final backgroundPaint = ui.Paint()
    ..shader = ui.Gradient.linear(
      ui.Offset(framedCanvasWidth / 2, 0),
      ui.Offset(framedCanvasWidth / 2, framedCanvasHeight),
      [gradientStart, gradientEnd],
    );
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, framedCanvasWidth, framedCanvasHeight),
    backgroundPaint,
  );

  // Promo text.
  final promo = _promoTexts[name];
  if (promo != null) {
    const textMaxWidth = 1150.0;
    const titleFontSize = 120.0;
    const subtitleFontSize = 44.0;
    const titleToSubtitleSpacing = 24.0;

    final title = _buildParagraph(
      promo.title,
      titleFontSize,
      ui.FontWeight.bold,
      textMaxWidth,
    );
    final subtitle = _buildParagraph(
      promo.subtitle,
      subtitleFontSize,
      ui.FontWeight.normal,
      textMaxWidth,
    );

    // Center the text block vertically in the top margin above the phone.
    final textBlockHeight =
        title.height + titleToSubtitleSpacing + subtitle.height;
    final titleY = (frameTopMargin - textBlockHeight) / 2;
    final subtitleY = titleY + title.height + titleToSubtitleSpacing;
    final titleX = (framedCanvasWidth - title.width) / 2;
    final subtitleX = (framedCanvasWidth - subtitle.width) / 2;

    canvas.drawParagraph(title, ui.Offset(titleX, titleY));
    canvas.drawParagraph(subtitle, ui.Offset(subtitleX, subtitleY));
  }

  final screenWidth = profile.physicalWidth;
  final screenHeight = profile.physicalHeight;
  final bodyWidth = screenWidth + frameBezel * 2;
  final bodyHeight = screenHeight + frameBezel * 2;
  final bodyLeft = (framedCanvasWidth - bodyWidth) / 2;
  final bodyTop = frameTopMargin;
  final bodyRight = bodyLeft + bodyWidth;

  final bodyRRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
    const ui.Radius.circular(bodyCornerRadius),
  );

  // Soft drop shadow.
  final shadowPaint = ui.Paint()
    ..color = const ui.Color(0x66000000)
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 30);
  canvas.drawRRect(bodyRRect, shadowPaint);

  // Phone body.
  final bodyPaint = ui.Paint()..color = const ui.Color(0xFF1F1F1F);
  canvas.drawRRect(bodyRRect, bodyPaint);

  // Pixel-style side buttons (right edge).
  final buttonPaint = ui.Paint()..color = const ui.Color(0xFF3A3A3A);
  const buttonWidth = 6.0;
  const buttonRadius = 3.0;

  void drawButton(double top, double height) {
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(bodyRight - 2, top, buttonWidth, height),
        const ui.Radius.circular(buttonRadius),
      ),
      buttonPaint,
    );
  }

  drawButton(bodyTop + 360, 70); // volume up
  drawButton(bodyTop + 450, 70); // volume down
  drawButton(bodyTop + 660, 85); // power

  // Screen content.
  final screenRect = ui.Rect.fromLTWH(
    bodyLeft + frameBezel,
    bodyTop + frameBezel,
    screenWidth,
    screenHeight,
  );
  final screenRRect = ui.RRect.fromRectAndRadius(
    screenRect,
    const ui.Radius.circular(screenCornerRadius),
  );
  canvas.save();
  canvas.clipRRect(screenRRect);
  canvas.drawImageRect(
    rawImage,
    ui.Rect.fromLTWH(
      0,
      0,
      rawImage.width.toDouble(),
      rawImage.height.toDouble(),
    ),
    screenRect,
    ui.Paint(),
  );
  canvas.restore();

  // Front camera punch-hole.
  final cameraPaint = ui.Paint()..color = const ui.Color(0xFF000000);
  canvas.drawCircle(
    ui.Offset(framedCanvasWidth / 2, bodyTop + frameBezel / 2),
    5,
    cameraPaint,
  );

  final picture = recorder.endRecording();
  return picture.toImage(framedCanvasWidth.toInt(), framedCanvasHeight.toInt());
}
