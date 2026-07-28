// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/i18n.dart';
import '../providers/providers.dart';
import '../urls.dart';
import 'helpers.dart' as helpers;

/// Donation tier cards shown inside the Support Us bottom sheet.
///
/// Hidden when billing is unavailable (e.g. Windows); while product prices
/// load, fallback prices are displayed.
class DonateSection extends ConsumerWidget {
  const DonateSection({super.key});

  static const _items = [
    (id: iapDonate5, emoji: '☕', fallbackPrice: r'$5'),
    (id: iapDonate10, emoji: '🍕', fallbackPrice: r'$10'),
    (id: iapDonate15, emoji: '🎁', fallbackPrice: r'$15'),
    (id: iapDonate3monthly, emoji: '📆', fallbackPrice: r'$3/mo'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const labelBig = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    const emojiBig = TextStyle(fontSize: 30);
    final state = ref.watch(donationsProvider).valueOrNull;
    // Hide the section once billing is known to be unavailable (Windows,
    // no store access); while loading, show fallback prices.
    if (state != null && !state.available) return const SizedBox.shrink();
    final products = state?.products ?? {};
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.t.donate,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (i, item) in _items.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: helpers.EmojiCard(
                  emoji: item.emoji,
                  label: products[item.id]?.price ?? item.fallbackPrice,
                  onTap: () => _buy(context, ref, item.id),
                  border: helpers.outlinedBorder(context),
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  labelStyle: labelBig,
                  emojiStyle: emojiBig,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, String id) async {
    final result = await ref.read(donationsProvider.notifier).buy(id);
    if (!context.mounted || result == DonationResult.canceled) return;
    final message = switch (result) {
      DonationResult.purchased => context.t.donateThankYou,
      _ => context.t.donateFailed,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
