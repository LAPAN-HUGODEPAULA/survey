import 'dart:ui';

import 'package:flutter/material.dart';

enum DsToneProfile { patient, professional, admin }

@immutable
class DsToneTokens extends ThemeExtension<DsToneTokens> {
  const DsToneTokens({
    required this.profile,
    required this.emotionalVolume,
    required this.namedGreetingTemplate,
    required this.namedGreetingSuffix,
    required this.fallbackGreeting,
    required this.completionAcknowledgement,
    required this.waitingSupportMessage,
  });

  final DsToneProfile profile;
  final double emotionalVolume;
  final String namedGreetingTemplate;
  final String namedGreetingSuffix;
  final String fallbackGreeting;
  final String completionAcknowledgement;
  final String waitingSupportMessage;

  static const DsToneTokens patient = DsToneTokens(
    profile: DsToneProfile.patient,
    emotionalVolume: 0.9,
    namedGreetingTemplate: 'Olá, {nome}.',
    namedGreetingSuffix: 'Estamos com você em cada etapa.',
    fallbackGreeting: 'Olá! Estamos com você em cada etapa.',
    completionAcknowledgement:
        'Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde.',
    waitingSupportMessage:
        'Reserve o tempo que precisar. Estamos preparando tudo com cuidado para você.',
  );

  static const DsToneTokens professional = DsToneTokens(
    profile: DsToneProfile.professional,
    emotionalVolume: 0.58,
    namedGreetingTemplate: 'Olá, {nome}.',
    namedGreetingSuffix: 'Seguimos com clareza para a próxima etapa clínica.',
    fallbackGreeting: 'Olá. Seguimos com clareza para a próxima etapa clínica.',
    completionAcknowledgement:
        'Sessão concluída com sucesso. O registro clínico foi gerado e está pronto para sua revisão.',
    waitingSupportMessage:
        'Estamos preparando o resultado clínico com consistência. Isso leva apenas alguns instantes.',
  );

  static const DsToneTokens admin = DsToneTokens(
    profile: DsToneProfile.admin,
    emotionalVolume: 0.22,
    namedGreetingTemplate: 'Olá, {nome}.',
    namedGreetingSuffix: 'Seguimos com objetividade.',
    fallbackGreeting: 'Olá. Seguimos com objetividade.',
    completionAcknowledgement: 'Operação concluída com sucesso.',
    waitingSupportMessage:
        'Processamento em andamento. Continue quando estiver pronto.',
  );

  static DsToneTokens fromProfile(DsToneProfile profile) {
    switch (profile) {
      case DsToneProfile.patient:
        return patient;
      case DsToneProfile.professional:
        return professional;
      case DsToneProfile.admin:
        return admin;
    }
  }

  String salutationFor(String? userName, {String fallback = 'Olá.'}) {
    final resolvedName = userName?.trim();
    if (resolvedName == null || resolvedName.isEmpty) {
      return fallback;
    }
    return namedGreetingTemplate.replaceAll('{nome}', resolvedName);
  }

  String greetingFor(String? userName) {
    final resolvedName = userName?.trim();
    if (resolvedName == null || resolvedName.isEmpty) {
      return fallbackGreeting;
    }
    final salutation = salutationFor(resolvedName);
    return '$salutation $namedGreetingSuffix';
  }

  @override
  DsToneTokens copyWith({
    DsToneProfile? profile,
    double? emotionalVolume,
    String? namedGreetingTemplate,
    String? namedGreetingSuffix,
    String? fallbackGreeting,
    String? completionAcknowledgement,
    String? waitingSupportMessage,
  }) {
    return DsToneTokens(
      profile: profile ?? this.profile,
      emotionalVolume: emotionalVolume ?? this.emotionalVolume,
      namedGreetingTemplate:
          namedGreetingTemplate ?? this.namedGreetingTemplate,
      namedGreetingSuffix: namedGreetingSuffix ?? this.namedGreetingSuffix,
      fallbackGreeting: fallbackGreeting ?? this.fallbackGreeting,
      completionAcknowledgement:
          completionAcknowledgement ?? this.completionAcknowledgement,
      waitingSupportMessage:
          waitingSupportMessage ?? this.waitingSupportMessage,
    );
  }

  @override
  DsToneTokens lerp(ThemeExtension<DsToneTokens>? other, double t) {
    if (other is! DsToneTokens) {
      return this;
    }
    return DsToneTokens(
      profile: t < 0.5 ? profile : other.profile,
      emotionalVolume: lerpDouble(emotionalVolume, other.emotionalVolume, t) ??
          emotionalVolume,
      namedGreetingTemplate:
          t < 0.5 ? namedGreetingTemplate : other.namedGreetingTemplate,
      namedGreetingSuffix:
          t < 0.5 ? namedGreetingSuffix : other.namedGreetingSuffix,
      fallbackGreeting: t < 0.5 ? fallbackGreeting : other.fallbackGreeting,
      completionAcknowledgement:
          t < 0.5 ? completionAcknowledgement : other.completionAcknowledgement,
      waitingSupportMessage:
          t < 0.5 ? waitingSupportMessage : other.waitingSupportMessage,
    );
  }
}
