import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';

void main() {
  late HttpServer server;
  PersonaSkillRepository? repository;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    repository?.dispose();
    await server.close(force: true);
  });

  PersonaSkillRepository buildRepository() {
    repository = PersonaSkillRepository(
      client: Dio(
        BaseOptions(baseUrl: 'http://${server.address.address}:${server.port}'),
      ),
      requestPathBuilder: (path, [queryParameters]) => '/api/v1/$path',
    );
    return repository!;
  }

  test('listPersonaSkills maps API payload', () async {
    server.listen((request) async {
      expect(request.uri.path, '/api/v1/persona_skills/');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode([
            {
              'personaSkillKey': 'school_report',
              'name': 'Relatório escolar',
              'outputProfile': 'school_report',
              'instructions': 'Use linguagem formal.',
              'createdAt': '2026-03-31T00:00:00Z',
              'modifiedAt': '2026-03-31T00:00:00Z',
            },
          ]),
        );
      await request.response.close();
    });

    final skills = await buildRepository().listPersonaSkills();

    expect(skills, hasLength(1));
    expect(skills.first.personaSkillKey, 'school_report');
    expect(skills.first.outputProfile, 'school_report');
  });

  test('createPersonaSkill normalizes request payload', () async {
    server.listen((request) async {
      expect(request.uri.path, '/api/v1/persona_skills/');
      final payload =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      expect(payload['personaSkillKey'], 'school_report');
      expect(payload['outputProfile'], 'school_profile');
      expect(payload['name'], 'Relatório escolar');
      request.response
        ..statusCode = HttpStatus.created
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            ...payload,
            'createdAt': '2026-03-31T00:00:00Z',
            'modifiedAt': '2026-03-31T00:00:00Z',
          }),
        );
      await request.response.close();
    });

    final created = await buildRepository().createPersonaSkill(
      PersonaSkillDraft(
        personaSkillKey: ' School_Report ',
        name: ' Relatório escolar ',
        outputProfile: ' School_Profile ',
        instructions: ' Use linguagem formal. ',
      ),
    );

    expect(created.personaSkillKey, 'school_report');
    expect(created.outputProfile, 'school_profile');
    expect(created.name, 'Relatório escolar');
  });

  test('createPersonaSkill maps conflicts to a typed exception', () async {
    server.listen((request) async {
      request.response
        ..statusCode = HttpStatus.conflict
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'detail': 'Persona skill key already exists'}));
      await request.response.close();
    });

    expect(
      () => buildRepository().createPersonaSkill(
        PersonaSkillDraft(
          personaSkillKey: 'school_report',
          name: 'Relatório escolar',
          outputProfile: 'school_report',
          instructions: 'Use linguagem formal.',
        ),
      ),
      throwsA(isA<PersonaSkillConflictException>()),
    );
  });
}
