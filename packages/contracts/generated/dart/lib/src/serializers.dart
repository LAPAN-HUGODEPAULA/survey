//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:survey_backend_api/src/date_serializer.dart';
import 'package:survey_backend_api/src/model/date.dart';

import 'package:survey_backend_api/src/model/address.dart';
import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:survey_backend_api/src/model/answer.dart';
import 'package:survey_backend_api/src/model/chat_message.dart';
import 'package:survey_backend_api/src/model/chat_message_create.dart';
import 'package:survey_backend_api/src/model/chat_message_update.dart';
import 'package:survey_backend_api/src/model/chat_session.dart';
import 'package:survey_backend_api/src/model/chat_session_create.dart';
import 'package:survey_backend_api/src/model/chat_session_update.dart';
import 'package:survey_backend_api/src/model/clinical_writer_alert.dart';
import 'package:survey_backend_api/src/model/clinical_writer_analysis_message.dart';
import 'package:survey_backend_api/src/model/clinical_writer_analysis_request.dart';
import 'package:survey_backend_api/src/model/clinical_writer_analysis_response.dart';
import 'package:survey_backend_api/src/model/clinical_writer_entity.dart';
import 'package:survey_backend_api/src/model/clinical_writer_hypothesis.dart';
import 'package:survey_backend_api/src/model/clinical_writer_knowledge_item.dart';
import 'package:survey_backend_api/src/model/clinical_writer_request.dart';
import 'package:survey_backend_api/src/model/clinical_writer_request_metadata.dart';
import 'package:survey_backend_api/src/model/clinical_writer_suggestion.dart';
import 'package:survey_backend_api/src/model/document_export_request.dart';
import 'package:survey_backend_api/src/model/document_preview.dart';
import 'package:survey_backend_api/src/model/document_preview_request.dart';
import 'package:survey_backend_api/src/model/document_record.dart';
import 'package:survey_backend_api/src/model/instructions.dart';
import 'package:survey_backend_api/src/model/list_template_document_types200_response_inner.dart';
import 'package:survey_backend_api/src/model/patient.dart';
import 'package:survey_backend_api/src/model/professional_council.dart';
import 'package:survey_backend_api/src/model/question.dart';
import 'package:survey_backend_api/src/model/screener_login.dart';
import 'package:survey_backend_api/src/model/screener_model.dart';
import 'package:survey_backend_api/src/model/screener_password_recovery_request.dart';
import 'package:survey_backend_api/src/model/screener_profile.dart';
import 'package:survey_backend_api/src/model/screener_register.dart';
import 'package:survey_backend_api/src/model/survey.dart';
import 'package:survey_backend_api/src/model/survey_response.dart';
import 'package:survey_backend_api/src/model/survey_response_with_agent.dart';
import 'package:survey_backend_api/src/model/template_create_request.dart';
import 'package:survey_backend_api/src/model/template_document_type.dart';
import 'package:survey_backend_api/src/model/template_preview_request.dart';
import 'package:survey_backend_api/src/model/template_preview_response.dart';
import 'package:survey_backend_api/src/model/template_record.dart';
import 'package:survey_backend_api/src/model/template_update_request.dart';
import 'package:survey_backend_api/src/model/token.dart';
import 'package:survey_backend_api/src/model/transcription_request.dart';
import 'package:survey_backend_api/src/model/transcription_response.dart';
import 'package:survey_backend_api/src/model/transcription_segment.dart';

part 'serializers.g.dart';

@SerializersFor([
  Address,
  AgentResponse,
  Answer,
  ChatMessage,
  ChatMessageCreate,
  ChatMessageUpdate,
  ChatSession,
  ChatSessionCreate,
  ChatSessionUpdate,
  ClinicalWriterAlert,
  ClinicalWriterAnalysisMessage,
  ClinicalWriterAnalysisRequest,
  ClinicalWriterAnalysisResponse,
  ClinicalWriterEntity,
  ClinicalWriterHypothesis,
  ClinicalWriterKnowledgeItem,
  ClinicalWriterRequest,
  ClinicalWriterRequestMetadata,
  ClinicalWriterSuggestion,
  DocumentExportRequest,
  DocumentPreview,
  DocumentPreviewRequest,
  DocumentRecord,
  Instructions,
  ListTemplateDocumentTypes200ResponseInner,
  Patient,
  ProfessionalCouncil,
  Question,
  ScreenerLogin,
  ScreenerModel,
  ScreenerPasswordRecoveryRequest,
  ScreenerProfile,
  ScreenerRegister,
  Survey,
  SurveyResponse,$SurveyResponse,
  SurveyResponseWithAgent,
  TemplateCreateRequest,
  TemplateDocumentType,
  TemplatePreviewRequest,
  TemplatePreviewResponse,
  TemplateRecord,
  TemplateUpdateRequest,
  Token,
  TranscriptionRequest,
  TranscriptionResponse,
  TranscriptionSegment,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SurveyResponse)]),
        () => ListBuilder<SurveyResponse>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Survey)]),
        () => ListBuilder<Survey>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ListTemplateDocumentTypes200ResponseInner)]),
        () => ListBuilder<ListTemplateDocumentTypes200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ChatSession)]),
        () => ListBuilder<ChatSession>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(TemplateRecord)]),
        () => ListBuilder<TemplateRecord>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ChatMessage)]),
        () => ListBuilder<ChatMessage>(),
      )
      ..add(SurveyResponse.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
