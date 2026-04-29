import 'dart:math';

import 'package:flutter/material.dart';

class DsSurveyProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool includeSuccessPage;
  final bool showLabel;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  const DsSurveyProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
    this.includeSuccessPage = false,
    this.showLabel = false,
    this.padding = const EdgeInsets.only(bottom: 24.0),
    this.minHeight = 4,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = max(0, total);
    final safeIndex =
        max(0, min(currentIndex, safeTotal > 0 ? safeTotal - 1 : 0));
    final value = switch (safeTotal) {
      0 => 0.0,
      _ when includeSuccessPage && currentIndex >= safeTotal => 1.0,
      _ when includeSuccessPage => max(0.02, (safeIndex + 1) / (safeTotal + 1)),
      _ => (safeIndex + 1) / safeTotal,
    };

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Pergunta ${safeIndex + 1} de $safeTotal',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          LinearProgressIndicator(
            value: value,
            minHeight: minHeight,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
