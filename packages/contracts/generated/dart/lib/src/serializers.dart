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

import 'package:survey_backend_api/src/model/agent_response.dart';
import 'package:survey_backend_api/src/model/answer.dart';
import 'package:survey_backend_api/src/model/instructions.dart';
import 'package:survey_backend_api/src/model/patient.dart';
import 'package:survey_backend_api/src/model/question.dart';
import 'package:survey_backend_api/src/model/survey.dart';
import 'package:survey_backend_api/src/model/survey_response.dart';
import 'package:survey_backend_api/src/model/survey_response_with_agent.dart';

part 'serializers.g.dart';

@SerializersFor([
  AgentResponse,
  Answer,
  Instructions,
  Patient,
  Question,
  Survey,
  SurveyResponse,$SurveyResponse,
  SurveyResponseWithAgent,
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
      ..add(SurveyResponse.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
