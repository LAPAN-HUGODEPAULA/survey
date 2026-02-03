import 'dart:math';

import 'package:flutter/material.dart';

class DsSurveyProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool showLabel;
  final EdgeInsetsGeometry padding;

  const DsSurveyProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
    this.showLabel = false,
    this.padding = const EdgeInsets.only(bottom: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = max(0, total);
    final safeIndex = max(0, min(currentIndex, safeTotal > 0 ? safeTotal - 1 : 0));
    final value = safeTotal == 0 ? 0.0 : (safeIndex + 1) / safeTotal;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${safeIndex + 1}/$safeTotal',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
      ),
    );
  }
}
