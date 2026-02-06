library;

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

class SurveyRepository {
  SurveyRepository({api.DefaultApi? apiClient, Dio? rawClient})
      : _api = apiClient ??
            api.DefaultApi(
              Dio(
                BaseOptions(
                  baseUrl: ApiConfig.dioBaseUrl,
                  headers: ApiConfig.defaultHeaders,
                ),
              ),
              api.standardSerializers,
            ),
        _rawClient = rawClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.dioBaseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            );

  final api.DefaultApi _api;
  final Dio _rawClient;

  Future<List<SurveyDraft>> listSurveys() async {
    final response = await _api.listSurveys();
    final BuiltList<api.Survey> data = response.data ?? BuiltList<api.Survey>();
    return data.map(_mapSurvey).toList(growable: false);
  }

  Future<SurveyDraft> fetchSurvey(String surveyId) async {
    final response = await _api.getSurvey(surveyId: surveyId);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Survey not found');
    }
    return _mapSurvey(data);
  }

  Future<SurveyDraft> createSurvey(SurveyDraft draft) async {
    final payload = _toApiSurvey(draft, includeId: false);
    final response = await _api.createSurvey(survey: payload);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Survey not created');
    }
    return _mapSurvey(data);
  }

  Future<SurveyDraft> updateSurvey(SurveyDraft draft) async {
    if (draft.id == null || draft.id!.isEmpty) {
      throw const FormatException('Survey id is required');
    }
    final payload = _toApiSurvey(draft, includeId: true);
    final response = await _api.updateSurvey(surveyId: draft.id!, survey: payload);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Survey not updated');
    }
    return _mapSurvey(data);
  }

  Future<void> deleteSurvey(String surveyId) async {
    await _api.deleteSurvey(surveyId: surveyId);
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
    });
  }

  void dispose() {
    _rawClient.close(force: true);
  }
}
