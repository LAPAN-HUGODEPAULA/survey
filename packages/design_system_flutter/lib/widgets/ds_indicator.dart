import 'package:flutter/material.dart';

class DsStatusIndicator extends StatelessWidget {
  const DsStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.liveRegion = false,
  });

  final String label;
  final Color color;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: liveRegion,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class DsRecordingIndicator extends StatelessWidget {
  const DsRecordingIndicator({
    super.key,
    required this.seconds,
  });

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(opacity: value, child: child);
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Recording $minutes:$remaining',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
