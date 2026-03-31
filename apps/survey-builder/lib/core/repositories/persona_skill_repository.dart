import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

typedef RequestPathBuilder =
    String Function(String path, [Map<String, dynamic>? queryParameters]);

class PersonaSkillRepository {
  PersonaSkillRepository({Dio? client, RequestPathBuilder? requestPathBuilder})
    : _client = client ?? ApiConfig.createDio(),
      _requestPathBuilder = requestPathBuilder ?? ApiConfig.requestPath;

  final Dio _client;
  final RequestPathBuilder _requestPathBuilder;

  Future<List<PersonaSkillDraft>> listPersonaSkills() async {
    try {
      final response = await _client.get<Object?>(
        _requestPathBuilder('persona_skills/'),
      );
      final decoded = _coerceJson(response.data);
      if (decoded is! List) {
        throw const FormatException('Resposta inesperada ao listar personas.');
      }
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map((entry) => _mapPersonaSkill(Map<String, dynamic>.from(entry)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao listar personas.');
    }
  }

  Future<PersonaSkillDraft> createPersonaSkill(PersonaSkillDraft draft) async {
    try {
      final response = await _client.post<Object?>(
        _requestPathBuilder('persona_skills/'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao criar persona.');
    }
  }

  Future<PersonaSkillDraft> updatePersonaSkill(PersonaSkillDraft draft) async {
    try {
      final response = await _client.put<Object?>(
        _requestPathBuilder('persona_skills/${draft.personaSkillKey}'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao atualizar persona.');
    }
  }

  Future<void> deletePersonaSkill(String personaSkillKey) async {
    try {
      await _client.delete<Object?>(
        _requestPathBuilder('persona_skills/$personaSkillKey'),
      );
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao excluir persona.');
    }
  }

  PersonaSkillDraft _mapResponse(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      return _mapPersonaSkill(decoded);
    }
    if (decoded is Map) {
      return _mapPersonaSkill(Map<String, dynamic>.from(decoded));
    }
    throw const FormatException('Resposta inesperada da persona.');
  }

  PersonaSkillDraft _mapPersonaSkill(Map<String, dynamic> json) {
    return PersonaSkillDraft(
      personaSkillKey: json['personaSkillKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      outputProfile: json['outputProfile']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      createdAt: _coerceDateTime(json['createdAt']),
      modifiedAt: _coerceDateTime(json['modifiedAt']),
    );
  }

  Map<String, dynamic> _toJson(PersonaSkillDraft draft) {
    return {
      'personaSkillKey': PersonaSkillFormSupport.normalizeKeyField(
        draft.personaSkillKey,
      ),
      'name': PersonaSkillFormSupport.normalizeTextField(draft.name),
      'outputProfile': PersonaSkillFormSupport.normalizeKeyField(
        draft.outputProfile,
      ),
      'instructions': PersonaSkillFormSupport.normalizeTextField(
        draft.instructions,
      ),
    };
  }

  DateTime? _coerceDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  dynamic _coerceJson(dynamic payload) {
    if (payload is String) {
      return jsonDecode(payload);
    }
    return payload;
  }

  PersonaSkillRepositoryException _mapError(
    DioException error, {
    required String fallbackMessage,
  }) {
    final detail = _extractDetail(error.response?.data);
    if (error.response?.statusCode == 409) {
      return PersonaSkillConflictException(
        detail.isEmpty ? 'Conflito ao salvar persona.' : detail,
      );
    }
    return PersonaSkillRepositoryException(
      detail.isEmpty ? fallbackMessage : detail,
    );
  }

  String _extractDetail(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String) {
        return detail;
      }
    } else if (decoded is Map) {
      final detail = decoded['detail'];
      if (detail is String) {
        return detail;
      }
    } else if (decoded is String) {
      return decoded;
    }
    return '';
  }

  void dispose() {
    _client.close(force: true);
  }
}

class PersonaSkillRepositoryException implements Exception {
  const PersonaSkillRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PersonaSkillConflictException extends PersonaSkillRepositoryException {
  const PersonaSkillConflictException(super.message);
}
