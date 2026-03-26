import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class SurveyRepository {
  SurveyRepository({api.DefaultApi? apiClient, Dio? rawClient})
    : _api =
          apiClient ??
          api.DefaultApi(ApiConfig.createDio(), api.standardSerializers),
      _rawClient = rawClient ?? ApiConfig.createDio();

  final api.DefaultApi _api;
  final Dio _rawClient;

  Future<List<SurveyDraft>> listSurveys() async {
    try {
      final response = await _api.listSurveys();
      final BuiltList<api.Survey> data =
          response.data ?? BuiltList<api.Survey>();
      return data.map(_mapSurvey).toList(growable: false);
    } on DioException {
      return _listSurveysRaw();
    }
  }

  Future<SurveyDraft> fetchSurvey(String surveyId) async {
    final response = await _api.getSurvey(surveyId: surveyId);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Questionário não encontrado');
    }
    return _mapSurvey(data);
  }

  Future<SurveyDraft> createSurvey(SurveyDraft draft) async {
    final payload = _toApiSurvey(draft, includeId: false);
    final response = await _api.createSurvey(survey: payload);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Questionário não criado');
    }
    return _mapSurvey(data);
  }

  Future<SurveyDraft> updateSurvey(SurveyDraft draft) async {
    if (draft.id == null || draft.id!.isEmpty) {
      throw const FormatException('ID do questionário é obrigatório');
    }
    final payload = _toApiSurvey(draft, includeId: true);
    final response = await _api.updateSurvey(
      surveyId: draft.id!,
      survey: payload,
    );
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Questionário não atualizado');
    }
    return _mapSurvey(data);
  }

  Future<void> deleteSurvey(String surveyId) async {
    await _api.deleteSurvey(surveyId: surveyId);
  }

  Future<String> exportSurveys() async {
    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('surveys/export'),
      options: Options(responseType: ResponseType.plain),
    );
    final data = response.data;
    if (data is String) {
      return data;
    }
    return jsonEncode(data);
  }

  Future<List<SurveyDraft>> _listSurveysRaw() async {
    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('surveys/'),
    );
    final payload = response.data;
    final decoded = _coerceJson(payload);
    if (decoded is! List) {
      throw const FormatException(
        'Resposta inesperada ao listar questionários.',
      );
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map((entry) => _mapJsonSurvey(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  SurveyDraft _mapSurvey(api.Survey source) {
    return SurveyDraft(
      id: source.id,
      surveyDisplayName: source.surveyDisplayName,
      surveyName: source.surveyName,
      surveyDescription: source.surveyDescription,
      creatorId: source.creatorId,
      createdAt: source.createdAt.toLocal(),
      modifiedAt: source.modifiedAt.toLocal(),
      instructions: InstructionsDraft(
        preamble: source.instructions.preamble,
        questionText: source.instructions.questionText,
        answers: source.instructions.answers.toList(growable: true),
      ),
      questions: source.questions
          .map(
            (q) => QuestionDraft(
              id: q.id,
              questionText: q.questionText,
              answers: q.answers.toList(growable: true),
            ),
          )
          .toList(growable: true),
      finalNotes: source.finalNotes,
      prompt: source.prompt == null
          ? null
          : SurveyPromptReferenceDraft(
              promptKey: source.prompt!.promptKey,
              name: source.prompt!.name,
            ),
    );
  }

  api.Survey _toApiSurvey(SurveyDraft draft, {required bool includeId}) {
    return api.Survey((builder) {
      if (includeId) {
        builder.id = draft.id;
      }
      builder.surveyDisplayName = draft.surveyDisplayName.trim();
      builder.surveyName = draft.surveyName.trim();
      builder.surveyDescription = draft.surveyDescription.trim();
      builder.creatorId = draft.creatorId.trim();
      builder.createdAt = draft.createdAt.toUtc();
      builder.modifiedAt = draft.modifiedAt.toUtc();
      builder.finalNotes = draft.finalNotes.trim();
      builder.instructions.update((instructions) {
        instructions
          ..preamble = draft.instructions.preamble.trim()
          ..questionText = draft.instructions.questionText.trim()
          ..answers.replace(
            draft.instructions.answers
                .map((answer) => answer.trim())
                .where((answer) => answer.isNotEmpty)
                .toList(),
          );
      });
      builder.questions.replace(
        draft.questions.map((question) {
          return api.Question((questionBuilder) {
            questionBuilder
              ..id = question.id
              ..questionText = question.questionText.trim()
              ..answers.replace(
                question.answers
                    .map((answer) => answer.trim())
                    .where((answer) => answer.isNotEmpty)
                    .toList(),
              );
          });
        }).toList(),
      );
      if (draft.prompt == null) {
        builder.prompt = null;
      } else {
        builder.prompt.replace(
          api.SurveyPromptReference((promptBuilder) {
            promptBuilder
              ..promptKey = draft.prompt!.promptKey
              ..name = draft.prompt!.name;
          }),
        );
      }
    });
  }

  SurveyDraft _mapJsonSurvey(Map<String, dynamic> source) {
    final now = DateTime.now();
    final instructions = _coerceMap(source['instructions']);
    final questions = _coerceList(source['questions']);

    return SurveyDraft(
      id: source['_id']?.toString(),
      surveyDisplayName: _coerceString(source['surveyDisplayName']),
      surveyName: _coerceString(source['surveyName']),
      surveyDescription: _coerceString(source['surveyDescription']),
      creatorId: _coerceString(source['creatorId']),
      createdAt: _coerceDateTime(source['createdAt']) ?? now,
      modifiedAt: _coerceDateTime(source['modifiedAt']) ?? now,
      instructions: InstructionsDraft(
        preamble: _coerceString(instructions['preamble']),
        questionText: _coerceString(instructions['questionText']),
        answers: _coerceStringList(instructions['answers']),
      ),
      questions: _mapQuestions(questions),
      finalNotes: _coerceString(source['finalNotes']),
      prompt: _mapPrompt(_coerceMap(source['prompt'])),
    );
  }

  List<QuestionDraft> _mapQuestions(List<dynamic> source) {
    final result = <QuestionDraft>[];
    for (var i = 0; i < source.length; i += 1) {
      final entry = source[i];
      if (entry is! Map) {
        continue;
      }
      final question = Map<String, dynamic>.from(entry);
      final id = question['id'];
      result.add(
        QuestionDraft(
          id: id is int ? id : int.tryParse(id?.toString() ?? '') ?? (i + 1),
          questionText: _coerceString(question['questionText']),
          answers: _coerceStringList(question['answers']),
        ),
      );
    }
    return result;
  }

  SurveyPromptReferenceDraft? _mapPrompt(Map<String, dynamic> source) {
    if (source.isEmpty) {
      return null;
    }
    final promptKey = _coerceString(source['promptKey']);
    final name = _coerceString(source['name']);
    if (promptKey.isEmpty || name.isEmpty) {
      return null;
    }
    return SurveyPromptReferenceDraft(
      promptKey: promptKey,
      name: name,
    );
  }

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  List<dynamic> _coerceList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const [];
  }

  List<String> _coerceStringList(dynamic value) {
    if (value is List) {
      return value
          .map((entry) => entry?.toString() ?? '')
          .where((v) => v.isNotEmpty)
          .toList();
    }
    return [''];
  }

  String _coerceString(dynamic value) {
    return value?.toString() ?? '';
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

  void dispose() {
    _rawClient.close(force: true);
  }
}
