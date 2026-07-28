// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:backend/backend.dart' as backend;
import '../i18n/i18n.dart';

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
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
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
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          errorText: error != null ? (t[error!] as String? ?? error) : null,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}

String categoryEmoji(backend.Category cat) => switch (cat) {
  backend.Category.oil => '🛢️',
  backend.Category.fuel => '⛽',
  backend.Category.cleaning => '🧼',
  backend.Category.diagnostic => '🔍',
  backend.Category.electronics => '⚡',
  backend.Category.repair => '🔧',
  backend.Category.replacement => '🔄',
  backend.Category.parking => '🅿️',
  backend.Category.insurance => '🛡️',
  backend.Category.tiresWheels => '🛞',
  backend.Category.taxFees => '📄',
};

String categoryLabel(backend.Category cat, BuildContext context) {
  final t = Translations.of(context);
  return switch (cat) {
    backend.Category.oil => t.catOil,
    backend.Category.fuel => t.catFuel,
    backend.Category.cleaning => t.catCleaning,
    backend.Category.diagnostic => t.catDiagnostic,
    backend.Category.electronics => t.catElectronics,
    backend.Category.repair => t.catRepair,
    backend.Category.replacement => t.catReplacement,
    backend.Category.parking => t.catParking,
    backend.Category.insurance => t.catInsurance,
    backend.Category.tiresWheels => t.catTiresWheels,
    backend.Category.taxFees => t.catTaxFees,
  };
}

String monthName(BuildContext context, int month) => switch (month) {
  1 => context.t.january,
  2 => context.t.february,
  3 => context.t.march,
  4 => context.t.april,
  5 => context.t.may,
  6 => context.t.june,
  7 => context.t.july,
  8 => context.t.august,
  9 => context.t.september,
  10 => context.t.october,
  11 => context.t.november,
  12 => context.t.december,
  _ => '',
};

class EmojiCard extends StatelessWidget {
  const EmojiCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.border,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(2),
    this.labelStyle,
    this.emojiStyle,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final BoxDecoration border;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? labelStyle;
  final TextStyle? emojiStyle;

  @override
  Widget build(BuildContext context) {
    var content = [
      Text(
        emoji,
        textAlign: TextAlign.center,
        style: emojiStyle ?? const TextStyle(fontSize: 26),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: labelStyle ?? const TextStyle(fontSize: 11),
      ),
    ];
    // Material clips Ink's decoration during scroll; bare Ink in ListView
    // paints the border independently from content.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: border,
          child: Center(
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const deleteIcon = Icon(Icons.delete_outline, color: Colors.red, size: 24);

const _btnPad = EdgeInsets.symmetric(horizontal: 28, vertical: 8);
const _btnShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

Widget cancelButton({required VoidCallback onPressed, required String label}) =>
    TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: _btnPad, shape: _btnShape),
      child: Text(label),
    );

Widget deleteButton(
  BuildContext context, {
  required VoidCallback onPressed,
  required String label,
}) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(
    padding: _btnPad,
    backgroundColor: Theme.of(context).colorScheme.error,
    foregroundColor: Theme.of(context).colorScheme.onError,
    shape: _btnShape,
  ),
  child: Text(label),
);

AlertDialog styledDialog({
  required Widget title,
  Widget? content,
  List<Widget>? actions,
  MainAxisAlignment? actionsAlignment,
}) => AlertDialog(
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
  title: title,
  content: content,
  actions: actions,
  actionsAlignment: actionsAlignment,
);

extension DateTimeFormatting on BuildContext {
  String formatCompactDate(DateTime date) =>
      MaterialLocalizations.of(this).formatCompactDate(date);
}

Column subColumn(
  BuildContext context,
  String label,
  String value, {
  Color? valueColor,
}) {
  final labelStyle = TextStyle(
    fontSize: 12,
    letterSpacing: 0.6,
    color: Theme.of(context).colorScheme.outline,
  );
  final valueStyle = TextStyle(fontWeight: FontWeight.w600, color: valueColor);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: labelStyle,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      Text(value, style: valueStyle, overflow: TextOverflow.ellipsis),
    ],
  );
}

BoxDecoration outlinedBorder(BuildContext context, {double radius = 8}) =>
    BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(radius),
    );

Widget outlinedTile(
  BuildContext context,
  Widget child, {
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    decoration: outlinedBorder(context),
    padding: padding,
    child: child,
  );
}

TextStyle costTextStyle(BuildContext context) => TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.error,
);

Text costText(
  BuildContext context, {
  required int value,
  required backend.Currency currency,
}) {
  return Text(
    backend.formatCurrency(value, currency),
    style: costTextStyle(context),
  );
}

TextStyle outlinedTextStyle(BuildContext context) => TextStyle(
  fontSize: 12,
  letterSpacing: 0.6,
  color: Theme.of(context).colorScheme.outline,
);

Icon iconClickable(BuildContext context) => Icon(
  Icons.chevron_right,
  size: 20,
  color: Theme.of(context).colorScheme.outline,
);

const _githubSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16">
  <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38
    0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13
    -.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66
    .07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15
    -.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0
    1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82
    1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01
    1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
</svg>''';

Widget githubIcon({double size = 24, Color? color}) => SvgPicture.string(
  _githubSvg,
  width: size,
  height: size,
  colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
);

/// Wraps [showModalBottomSheet] with the app's common styling.
void showAppBottomSheet(BuildContext context, WidgetBuilder builder) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: maxContentWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: builder,
  );
}

/// Maximum width used to keep pages readable on wide desktop/tablet windows.
const double maxContentWidth = 760;

/// Centers [child] and constrains its width to [maxContentWidth].
/// On narrow screens the child fills the available width.
class CenteredMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
