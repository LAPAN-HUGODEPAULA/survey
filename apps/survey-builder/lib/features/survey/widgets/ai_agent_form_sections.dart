import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/features/survey/controllers/ai_agent_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class AIAgentDetailsSection extends StatelessWidget {
  const AIAgentDetailsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AIAgentFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Endpoint do agente',
      child: Column(
        children: [
          DsNormalizedKeyField(
            controller: controller.agentKeyController,
            readOnly: controller.isEditing,
            label: 'Chave do agente *',
            helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(labelText: 'Nome *'),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: controller.providerType,
            decoration: const InputDecoration(labelText: 'Tipo de provedor *'),
            items: const [
              DropdownMenuItem(
                value: 'openai_compatible',
                child: Text('OpenAI compatível'),
              ),
              DropdownMenuItem(value: 'glm', child: Text('GLM')),
              DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setProviderType(value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://host:porta/v1',
            ),
            validator: (value) {
              if (controller.providerType != 'openai_compatible') {
                return null;
              }
              return SurveyAuthoringValidators.required(value);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.apiKeyEnvVarController,
            decoration: const InputDecoration(
              labelText: 'Variável de API key *',
              hintText: 'AI_API_KEY',
            ),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.defaultModelController,
            decoration: const InputDecoration(
              labelText: 'Modelo padrão *',
              hintText: 'qwen2.5-coder:7b',
            ),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.notesController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Notas',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class AIAgentCapabilitiesSection extends StatelessWidget {
  const AIAgentCapabilitiesSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AIAgentFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Capacidades',
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Agente habilitado'),
            value: controller.enabled,
            onChanged: controller.setEnabled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Chat completions OpenAI'),
            value: controller.supportsOpenAIChatCompletions,
            onChanged: controller.setSupportsOpenAIChatCompletions,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('response_format'),
            value: controller.supportsResponseFormat,
            onChanged: controller.setSupportsResponseFormat,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('RAG'),
            value: controller.supportsRag,
            onChanged: controller.setSupportsRag,
          ),
        ],
      ),
    );
  }
}
