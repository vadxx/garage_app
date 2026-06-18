// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
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

class EmojiCard extends StatelessWidget {
  const EmojiCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.border,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(2),
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final BoxDecoration border;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    var content = [
      Text(
        emoji,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
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

Widget outlinedTile(
  BuildContext context,
  Widget child, {
  EdgeInsetsGeometry? padding,
}) {
  final border = BoxDecoration(
    border: Border.all(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: 1.5,
    ),
    borderRadius: BorderRadius.circular(8),
  );
  return Container(decoration: border, padding: padding, child: child);
}
