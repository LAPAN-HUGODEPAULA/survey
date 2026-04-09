import 'dart:ui';

import 'package:design_system_flutter/theme/ds_tone_tokens.dart';
import 'package:flutter/material.dart';

class DsEmotionalToneProvider extends InheritedWidget {
  const DsEmotionalToneProvider({
    super.key,
    required this.profile,
    required super.child,
    this.tokens,
  });

  final DsToneProfile profile;
  final DsToneTokens? tokens;

  static DsEmotionalToneProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DsEmotionalToneProvider>();
  }

  static DsToneProfile resolveProfile(BuildContext context) {
    final provider = maybeOf(context);
    if (provider != null) {
      return provider.profile;
    }

    final themeTokens = Theme.of(context).extension<DsToneTokens>();
    if (themeTokens != null) {
      return themeTokens.profile;
    }

    return DsToneProfile.professional;
  }

  static DsToneTokens resolveTokens(BuildContext context) {
    final provider = maybeOf(context);
    final themeTokens = Theme.of(context).extension<DsToneTokens>();
    final profile = provider?.profile ?? themeTokens?.profile;

    if (provider?.tokens != null) {
      return provider!.tokens!;
    }

    if (themeTokens != null && profile == themeTokens.profile) {
      return themeTokens;
    }

    return DsToneTokens.fromProfile(profile ?? DsToneProfile.professional);
  }

  static Duration resolveMotionDuration(
    BuildContext context, {
    Duration base = const Duration(milliseconds: 220),
  }) {
    final volume = resolveTokens(context).emotionalVolume;
    final factor = lerpDouble(0.82, 1.28, volume) ?? 1;
    return Duration(milliseconds: (base.inMilliseconds * factor).round());
  }

  static Curve resolveMotionCurve(BuildContext context) {
    final volume = resolveTokens(context).emotionalVolume;
    if (volume >= 0.75) {
      return Curves.easeOutCubic;
    }
    if (volume <= 0.3) {
      return Curves.easeOut;
    }
    return Curves.easeOutQuad;
  }

  @override
  bool updateShouldNotify(DsEmotionalToneProvider oldWidget) {
    return profile != oldWidget.profile || tokens != oldWidget.tokens;
  }
}
