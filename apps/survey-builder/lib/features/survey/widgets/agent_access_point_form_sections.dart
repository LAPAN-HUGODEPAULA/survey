import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:runtime_agent_access_points/runtime_agent_access_points.dart';
import 'package:survey_builder/features/survey/controllers/agent_access_point_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class AgentAccessPointRoutingSection extends StatelessWidget {
  const AgentAccessPointRoutingSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AgentAccessPointFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Roteamento do acesso',
      subtitle:
          'Escolha um ponto de injeção suportado para preencher automaticamente chave, superfície e fluxo com o menor esforço possível.',
      child: Column(
        children: [
          DropdownButtonFormField<String?>(
            initialValue: controller.selectedInjectionPointKey,
            decoration: const InputDecoration(
              labelText: 'Ponto de injeção suportado',
              helperText:
                  'Selecione um fluxo conhecido do runtime ou mantenha em Personalizado.',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Personalizado'),
              ),
              ...RuntimeAccessPointCatalog.configurable.map(
                (descriptor) => DropdownMenuItem<String?>(
                  value: descriptor.accessPointKey,
                  child: Text(descriptor.surfaceLabel),
                ),
              ),
            ],
            onChanged: controller.handleInjectionPointChanged,
          ),
          if (controller.selectedInjectionPoint != null) ...[
            const SizedBox(height: 12),
            DsInlineMessage(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.info,
                title: controller.selectedInjectionPoint!.name,
                message: controller.selectedInjectionPoint!.description,
              ),
              margin: EdgeInsets.zero,
            ),
          ],
          if (RuntimeAccessPointCatalog.observedOnly.isNotEmpty) ...[
            const SizedBox(height: 12),
            DsInlineMessage(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.neutral,
                title:
                    'Pontos observados no runtime fora do catálogo configurável',
                message: RuntimeAccessPointCatalog.observedOnly
                    .map(
                      (descriptor) =>
                          '${descriptor.surfaceLabel}: ${descriptor.notes}',
                    )
                    .join('\n'),
              ),
              margin: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do ponto de acesso *',
            ),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.keyController,
            readOnly:
                controller.isEditing ||
                controller.selectedInjectionPoint != null,
            decoration: const InputDecoration(
              labelText: 'Chave estável *',
              helperText: 'Ex.: survey_patient.thank_you.auto_analysis',
            ),
            validator: controller.validateAccessPointKey,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: controller.sourceApp,
            decoration: const InputDecoration(
              labelText: 'Superfície de origem *',
            ),
            items: const [
              DropdownMenuItem(
                value: 'survey-patient',
                child: Text('survey-patient'),
              ),
              DropdownMenuItem(
                value: 'survey-frontend',
                child: Text('survey-frontend'),
              ),
              DropdownMenuItem(
                value: 'clinical-narrative',
                child: Text('clinical-narrative'),
              ),
            ],
            onChanged: controller.selectedInjectionPoint != null
                ? null
                : (value) {
                    if (value != null) {
                      controller.setSourceApp(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.flowKeyController,
            readOnly: controller.selectedInjectionPoint != null,
            decoration: const InputDecoration(
              labelText: 'Fluxo de runtime *',
              helperText: 'Ex.: thank_you.auto_analysis',
            ),
            validator: controller.validateAccessPointKey,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: controller.surveyId,
            decoration: const InputDecoration(
              labelText: 'Survey associado',
              helperText:
                  'Selecione "Global" para uso independente de um questionário específico.',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Global'),
              ),
              ...controller.surveys.map(
                (survey) => DropdownMenuItem<String?>(
                  value: survey.id,
                  child: Text(survey.surveyDisplayName),
                ),
              ),
            ],
            onChanged: controller.setSurveyId,
          ),
        ],
      ),
    );
  }
}

class AgentAccessPointAssignmentSection extends StatelessWidget {
  const AgentAccessPointAssignmentSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AgentAccessPointFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Vinculações de IA',
      subtitle:
          'Associe o prompt e a persona usados por este ponto de acesso para produzir a saída esperada.',
      child: Column(
        children: [
          DropdownButtonFormField<String?>(
            initialValue: controller.promptKey,
            decoration: const InputDecoration(
              labelText: 'Prompt do questionário *',
            ),
            items: [
              if (controller.surveyId != null)
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Herdar do questionário'),
                ),
              ...AgentAccessPointFormController.localPromptOptions.map(
                (option) => DropdownMenuItem<String?>(
                  value: option.$1,
                  child: Text('${option.$2} · ${option.$1}'),
                ),
              ),
              ...controller.prompts
                  .map(
                    (prompt) => DropdownMenuItem<String?>(
                      value: prompt.promptKey,
                      child: Text(prompt.name),
                    ),
                  )
                  .where(
                    (item) => !AgentAccessPointFormController.localPromptOptions
                        .any((option) => option.$1 == item.value),
                  ),
            ],
            onChanged: controller.setPromptKey,
          ),
          if (controller.promptSelectionError != null)
            _InlineFieldError(message: controller.promptSelectionError!),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: controller.personaSkillKey,
            decoration: const InputDecoration(labelText: 'Persona *'),
            items: [
              if (controller.surveyId != null)
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Herdar do questionário'),
                ),
              ...controller.personas.map(
                (persona) => DropdownMenuItem<String?>(
                  value: persona.personaSkillKey,
                  child: Text('${persona.name} · ${persona.outputProfile}'),
                ),
              ),
            ],
            onChanged: controller.setPersonaSkillKey,
          ),
          if (controller.personaSelectionError != null)
            _InlineFieldError(message: controller.personaSelectionError!),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição operacional',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class AgentAccessPointAiConfigSection extends StatelessWidget {
  const AgentAccessPointAiConfigSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AgentAccessPointFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Configuração de IA',
      subtitle:
          'Configure a redundância, escolha de modelos, temperatura e comportamento de raciocínio para este ponto de acesso.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Usar rota de agentes neste access point'),
            subtitle: const Text(
              'A seleção de agentes abaixo controla o modelo primário e os fallbacks deste runtime.',
            ),
            value: true,
            onChanged: null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: controller.primaryProvider,
            decoration: const InputDecoration(labelText: 'Agente primário *'),
            items: controller.agentMenuItems(
              currentValue: controller.primaryProvider,
            ),
            onChanged: controller.useGlobalAiSettings
                ? null
                : (value) {
                    if (value != null) {
                      controller.setPrimaryProvider(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.primaryModelController,
            readOnly: controller.useGlobalAiSettings,
            decoration: const InputDecoration(
              labelText: 'Modelo primário *',
              helperText: 'Use o padrão do agente ou informe um override.',
            ),
            validator: controller.useGlobalAiSettings
                ? null
                : SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String?>(
            initialValue: controller.fallbackProvider,
            decoration: const InputDecoration(
              labelText: 'Agente de fallback',
              helperText: 'Opcional. Usado se o primário falhar.',
            ),
            items: controller.fallbackAgentMenuItems(),
            onChanged: controller.useGlobalAiSettings
                ? null
                : controller.setFallbackProvider,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.fallbackModelController,
            readOnly: controller.useGlobalAiSettings,
            decoration: const InputDecoration(
              labelText: 'Modelo de fallback',
              helperText: 'Opcional. Ex.: gemini-2.0-flash',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Temperatura: ${controller.temperature.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: controller.temperature,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: controller.temperature.toStringAsFixed(1),
            onChanged: controller.useGlobalAiSettings
                ? null
                : controller.setTemperature,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: controller.reasoningEffort,
            decoration: const InputDecoration(
              labelText: 'Esforço de raciocínio (Reasoning)',
            ),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Baixo (Flash)')),
              DropdownMenuItem(value: 'medium', child: Text('Médio')),
              DropdownMenuItem(value: 'high', child: Text('Alto (Reasoning)')),
            ],
            onChanged: controller.useGlobalAiSettings
                ? null
                : (value) {
                    if (value != null) {
                      controller.setReasoningEffort(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Habilitar cache de entrada'),
            subtitle: const Text('Otimiza custos para prompts repetitivos.'),
            value: controller.enableCaching,
            onChanged: controller.useGlobalAiSettings
                ? null
                : controller.setEnableCaching,
          ),
        ],
      ),
    );
  }
}

class AgentAccessPointOrchestratorSection extends StatelessWidget {
  const AgentAccessPointOrchestratorSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final AgentAccessPointFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Prompts do Orchestrator',
      subtitle:
          'Sobrescreva as instruções de lógica clínica base do sistema para este ponto de acesso.',
      child: Column(
        children: [
          TextFormField(
            controller: controller.systemPromptController,
            decoration: const InputDecoration(
              labelText: 'Sobrescrita do Prompt de Sistema (Lógica Clínica)',
              helperText:
                  'Opcional. Substitui a lógica de interpretação clínica deste ponto.',
            ),
            maxLines: 12,
          ),
        ],
      ),
    );
  }
}

class _InlineFieldError extends StatelessWidget {
  const _InlineFieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
