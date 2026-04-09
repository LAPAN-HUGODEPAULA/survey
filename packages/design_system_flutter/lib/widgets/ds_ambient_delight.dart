import 'dart:ui';

import 'package:design_system_flutter/widgets/ds_emotional_tone_provider.dart';
import 'package:flutter/material.dart';

class DsAmbientDelight extends StatefulWidget {
  const DsAmbientDelight({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration,
    this.highlightColor,
  });

  final Widget child;
  final bool enabled;
  final Duration? duration;
  final Color? highlightColor;

  @override
  State<DsAmbientDelight> createState() => _DsAmbientDelightState();
}

class _DsAmbientDelightState extends State<DsAmbientDelight> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) {
        return;
      }
      setState(() {
        _progress = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final volume =
        DsEmotionalToneProvider.resolveTokens(context).emotionalVolume;
    final duration = widget.duration ??
        DsEmotionalToneProvider.resolveMotionDuration(
          context,
          base: const Duration(milliseconds: 260),
        );
    final curve = DsEmotionalToneProvider.resolveMotionCurve(context);
    final highlightBase = widget.highlightColor ??
        theme.colorScheme.primary.withValues(
          alpha: lerpDouble(0.04, 0.14, volume) ?? 0.08,
        );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _progress),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final translateY = lerpDouble(8, 0, value) ?? 0;
        final opacity = lerpDouble(0.82, 1.0, value) ?? 1.0;
        final backgroundColor =
            Color.lerp(Colors.transparent, highlightBase, value * 0.35) ??
                Colors.transparent;

        return AnimatedContainer(
          duration: duration,
          curve: curve,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
