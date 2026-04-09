import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:flutter/material.dart';

/// Maps technical failures into actionable pt-BR guidance.
class DsErrorMapper {
  const DsErrorMapper._();

  static const String _genericMessage =
      'Não foi possível completar esta ação agora. Tente novamente em alguns instantes.';

  static String toUserMessage(
    Object? error, {
    String fallbackMessage = _genericMessage,
  }) {
    final statusCode = _extractStatusCode(error);
    if (statusCode != null) {
      return _messageForStatusCode(statusCode);
    }

    final normalized = error?.toString().toLowerCase() ?? '';
    if (normalized.contains('timeout')) {
      return 'A conexão demorou mais que o esperado. Verifique sua internet e tente novamente.';
    }
    if (normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('network error') ||
        normalized.contains('connection error') ||
        normalized.contains('network is unreachable') ||
        normalized.contains('offline') ||
        normalized.contains('xhr error')) {
      return 'Você está sem conexão com a internet. Verifique sua rede e tente novamente.';
    }

    return fallbackMessage;
  }

  static DsFeedbackMessage toFeedbackMessage(
    Object? error, {
    VoidCallback? onRetry,
    DsStatusType severity = DsStatusType.error,
    String? title,
    String fallbackMessage = _genericMessage,
  }) {
    return DsFeedbackMessage(
      severity: severity,
      title: title ?? 'Não foi possível concluir a ação',
      message: toUserMessage(error, fallbackMessage: fallbackMessage),
      onRetry: onRetry,
    );
  }

  static int? _extractStatusCode(Object? error) {
    if (error == null) {
      return null;
    }

    try {
      final dynamic dynamicError = error;
      final int? statusCode = dynamicError.response?.statusCode as int?;
      if (statusCode != null) {
        return statusCode;
      }
    } catch (_) {
      // Ignore dynamic extraction failures.
    }

    final match = RegExp(
      r'(status(?:\s*code)?\D*)(\d{3})',
      caseSensitive: false,
    ).firstMatch(error.toString());
    if (match != null) {
      return int.tryParse(match.group(2)!);
    }
    return null;
  }

  static String _messageForStatusCode(int statusCode) {
    if (statusCode == 500) {
      return 'Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes.';
    }
    if (statusCode == 404) {
      return 'Não encontramos o conteúdo solicitado. Verifique as informações e tente novamente.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Sua sessão precisa ser atualizada para continuar. Faça login novamente.';
    }
    if (statusCode == 408 || statusCode == 429 || statusCode >= 500) {
      return 'Não foi possível concluir agora. Tente novamente em alguns instantes.';
    }
    return _genericMessage;
  }
}
