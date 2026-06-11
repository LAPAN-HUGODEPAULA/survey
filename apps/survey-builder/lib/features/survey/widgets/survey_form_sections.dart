import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/features/survey/controllers/survey_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';
import 'package:survey_builder/features/survey/widgets/html_rich_text_editor.dart';

class SurveyDetailsSection extends StatelessWidget {
  const SurveyDetailsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
    required this.descriptionEditorKey,
  });

  final SurveyFormController controller;
  final GlobalKey sectionKey;
  final GlobalKey<HtmlRichTextEditorState> descriptionEditorKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      eyebrow: 'Questionário',
      title: 'Detalhes do questionário',
      subtitle:
          'Organize os metadados principais e o conteúdo que contextualiza este formulário administrativo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsValidatedTextFormField(
            controller: controller.displayNameController,
            submitted: controller.hasSubmitted,
            decoration: const InputDecoration(
              labelText: 'Nome de exibição do questionário *',
            ),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          DsValidatedTextFormField(
            controller: controller.nameController,
            submitted: controller.hasSubmitted,
            decoration: const InputDecoration(
              labelText: 'Nome do questionário *',
            ),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          HtmlRichTextEditor(
            key: descriptionEditorKey,
            label: 'Descrição do questionário *',
            initialHtml: controller.descriptionHtml,
            errorText:
                controller.hasSubmitted &&
                    controller.isHtmlEmpty(controller.descriptionHtml)
                ? 'Descrição do questionário é obrigatória.'
                : null,
            onChanged: controller.updateDescriptionHtml,
          ),
          const SizedBox(height: 12),
          DsValidatedTextFormField(
            controller: controller.creatorIdController,
            submitted: controller.hasSubmitted,
            decoration: const InputDecoration(labelText: 'ID do criador *'),
            validator: SurveyAuthoringValidators.required,
          ),
        ],
      ),
    );
  }
}

class SurveyInstructionsSection extends StatelessWidget {
  const SurveyInstructionsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
    required this.preambleEditorKey,
    required this.finalNotesEditorKey,
  });

  final SurveyFormController controller;
  final GlobalKey sectionKey;
  final GlobalKey<HtmlRichTextEditorState> preambleEditorKey;
  final GlobalKey<HtmlRichTextEditorState> finalNotesEditorKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      eyebrow: 'Orientação',
      title: 'Instruções',
      subtitle:
          'Defina o preâmbulo e as respostas esperadas antes de publicar o questionário.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlRichTextEditor(
            key: preambleEditorKey,
            label: 'Preâmbulo *',
            initialHtml: controller.instructionsPreambleHtml,
            errorText:
                controller.hasSubmitted &&
                    controller.isHtmlEmpty(controller.instructionsPreambleHtml)
                ? 'Preâmbulo é obrigatório.'
                : null,
            onChanged: controller.updateInstructionsPreambleHtml,
          ),
          const SizedBox(height: 12),
          DsValidatedTextFormField(
            controller: controller.instructionsQuestionController,
            submitted: controller.hasSubmitted,
            decoration: const InputDecoration(labelText: 'Texto da pergunta *'),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          Text(
            'Respostas das instruções',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.instructionAnswers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: DsValidatedTextFormField(
                      key: ValueKey(
                        'instruction-answer-$index-${controller.instructionAnswers[index]}',
                      ),
                      initialValue: controller.instructionAnswers[index],
                      submitted: controller.hasSubmitted,
                      decoration: const InputDecoration(
                        labelText: 'Resposta *',
                      ),
                      validator: SurveyAuthoringValidators.required,
                      onChanged: (value) =>
                          controller.setInstructionAnswer(index, value),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remover resposta',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: controller.instructionAnswers.length <= 1
                        ? null
                        : () => controller.removeInstructionAnswer(index),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: controller.addInstructionAnswer,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar resposta de instrução'),
            ),
          ),
          const SizedBox(height: 12),
          HtmlRichTextEditor(
            key: finalNotesEditorKey,
            label: 'Notas finais *',
            initialHtml: controller.finalNotesHtml,
            errorText:
                controller.hasSubmitted &&
                    controller.isHtmlEmpty(controller.finalNotesHtml)
                ? 'Notas finais são obrigatórias.'
                : null,
            onChanged: controller.updateFinalNotesHtml,
          ),
        ],
      ),
    );
  }
}

class SurveyAiConfigSection extends StatelessWidget {
  const SurveyAiConfigSection({
    super.key,
    required this.controller,
    required this.promptSectionKey,
    required this.personaSectionKey,
  });

  final SurveyFormController controller;
  final GlobalKey promptSectionKey;
  final GlobalKey personaSectionKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DsSection(
          key: promptSectionKey,
          eyebrow: 'Automação',
          title: 'Prompt de IA',
          subtitle:
              'Associe um prompt reutilizável quando este questionário já tiver um fluxo de IA definido.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.loadingPrompts)
                const LinearProgressIndicator()
              else if (controller.promptLoadError != null)
                _ErrorPanel(
                  message:
                      'Não foi possível carregar os prompts: ${controller.promptLoadError}',
                )
              else ...[
                if (controller.availablePrompts.isEmpty)
                  DsFocusFrame(
                    child: const Text(
                      'Nenhum prompt disponível. O questionário usará o fluxo legado até que prompts sejam cadastrados.',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String?>(
                    key: const ValueKey('survey-prompt-selector'),
                    initialValue: controller.selectedPromptKey,
                    decoration: const InputDecoration(
                      labelText: 'Prompt de IA (opcional)',
                      helperText:
                          'Selecione um prompt reutilizável ou deixe vazio para manter o fluxo legado.',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Nenhum prompt'),
                      ),
                      ...controller.availablePrompts.map(
                        (prompt) => DropdownMenuItem<String?>(
                          value: prompt.promptKey,
                          child: Text(prompt.name),
                        ),
                      ),
                    ],
                    onChanged: controller.saving
                        ? null
                        : controller.setPromptKey,
                  ),
                ),
                if (controller.selectedPromptKey == null ||
                    controller.selectedPromptKey!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Nenhum prompt associado. O questionário poderá continuar usando o comportamento legado.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        DsSection(
          key: personaSectionKey,
          eyebrow: 'Narrativa',
          title: 'Configuração de persona',
          subtitle:
              'Mantenha a persona e o perfil de saída alinhados ao comportamento padrão esperado para os relatórios.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.loadingPersonaSkills)
                const LinearProgressIndicator()
              else if (controller.personaSkillLoadError != null)
                _ErrorPanel(
                  message:
                      'Não foi possível carregar as personas: ${controller.personaSkillLoadError}',
                )
              else ...[
                if (controller.availablePersonaSkills.isEmpty)
                  DsFocusFrame(
                    child: const Text(
                      'Nenhuma persona disponível. O questionário continuará usando os padrões legados até que personas sejam cadastradas.',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String?>(
                    key: const ValueKey('survey-persona-selector'),
                    initialValue: controller.selectedPersonaSkillKey,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Persona padrão (opcional)',
                      helperText:
                          'Selecione a persona padrão para relatórios sem sobrescritas no runtime.',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Nenhuma persona'),
                      ),
                      if (controller.hasStalePersonaSelection)
                        DropdownMenuItem<String?>(
                          value: controller.selectedPersonaSkillKey,
                          child: Text(
                            'Persona removida (${controller.selectedPersonaSkillKey!})',
                          ),
                        ),
                      ...controller.availablePersonaSkills.map(
                        (persona) => DropdownMenuItem<String?>(
                          value: persona.personaSkillKey,
                          child: Text(persona.name),
                        ),
                      ),
                    ],
                    onChanged: controller.saving
                        ? null
                        : controller.syncPersonaSelection,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String?>(
                    key: const ValueKey('survey-output-profile-selector'),
                    initialValue: controller.selectedOutputProfile,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Perfil de saída padrão (opcional)',
                      helperText:
                          'Esse perfil acompanha a persona padrão e é usado antes do fallback legado.',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Nenhum perfil'),
                      ),
                      if (controller.hasStaleOutputProfileSelection)
                        DropdownMenuItem<String?>(
                          value: controller.selectedOutputProfile,
                          child: Text(
                            'Perfil removido (${controller.selectedOutputProfile!})',
                          ),
                        ),
                      ...controller.availableOutputProfiles().map(
                        (outputProfile) => DropdownMenuItem<String?>(
                          value: outputProfile,
                          child: Text(outputProfile),
                        ),
                      ),
                    ],
                    onChanged: controller.saving
                        ? null
                        : controller.syncOutputProfileSelection,
                  ),
                ),
                if (controller.hasStalePersonaSelection ||
                    controller.hasStaleOutputProfileSelection)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'A configuração salva referencia uma persona removida. Escolha uma nova persona ou limpe a configuração antes de salvar.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SurveyQuestionsSection extends StatelessWidget {
  const SurveyQuestionsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final SurveyFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      eyebrow: 'Estrutura',
      title: 'Perguntas',
      subtitle:
          'Monte a ordem final do questionário e revise os rótulos exibidos nas prévias e nos relatórios.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Perguntas cadastradas',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DsOutlinedButton(
                label: 'Adicionar pergunta',
                icon: Icons.add_rounded,
                onPressed: controller.addQuestion,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.questions.isEmpty)
            Text(
              'Nenhuma pergunta adicionada ainda.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.questions.length,
            itemBuilder: (context, questionIndex) {
              final question = controller.questions[questionIndex];
              return DsSection(
                key: ValueKey('question-card-${question.id}'),
                tone: DsPanelTone.high,
                title: 'Pergunta ${questionIndex + 1}',
                action: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Mover para cima',
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: questionIndex == 0
                          ? null
                          : () => controller.moveQuestion(
                              questionIndex,
                              questionIndex - 1,
                            ),
                    ),
                    IconButton(
                      tooltip: 'Mover para baixo',
                      icon: const Icon(Icons.arrow_downward),
                      onPressed:
                          questionIndex == controller.questions.length - 1
                          ? null
                          : () => controller.moveQuestion(
                              questionIndex,
                              questionIndex + 1,
                            ),
                    ),
                    IconButton(
                      tooltip: 'Remover pergunta',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => controller.removeQuestion(questionIndex),
                    ),
                  ],
                ),
                child: _QuestionFields(
                  controller: controller,
                  questionIndex: questionIndex,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuestionFields extends StatelessWidget {
  const _QuestionFields({
    required this.controller,
    required this.questionIndex,
  });

  final SurveyFormController controller;
  final int questionIndex;

  @override
  Widget build(BuildContext context) {
    final question = controller.questions[questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsValidatedTextFormField(
          key: ValueKey('question-$questionIndex-${question.id}'),
          initialValue: question.questionText,
          submitted: controller.hasSubmitted,
          decoration: const InputDecoration(labelText: 'Texto da pergunta *'),
          validator: SurveyAuthoringValidators.required,
          onChanged: (value) =>
              controller.setQuestionText(questionIndex, value),
        ),
        const SizedBox(height: 12),
        DsValidatedTextFormField(
          key: ValueKey('question-label-$questionIndex-${question.id}'),
          initialValue: question.label,
          submitted: controller.hasSubmitted,
          decoration: const InputDecoration(
            labelText: 'Rótulo exibido no radar',
            helperText:
                'Opcional, usado no radar e nas prévias para pacientes.',
          ),
          onChanged: (value) =>
              controller.setQuestionLabel(questionIndex, value),
        ),
        const SizedBox(height: 4),
        Text(
          'Rótulo atual: ${question.label.trim().isNotEmpty ? question.label.trim() : 'Q${question.id}'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text('Respostas', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.answers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, answerIndex) {
            return Row(
              children: [
                Expanded(
                  child: DsValidatedTextFormField(
                    key: ValueKey(
                      'question-$questionIndex-answer-$answerIndex-${question.answers[answerIndex]}',
                    ),
                    initialValue: question.answers[answerIndex],
                    submitted: controller.hasSubmitted,
                    decoration: const InputDecoration(labelText: 'Resposta *'),
                    validator: SurveyAuthoringValidators.required,
                    onChanged: (value) => controller.setQuestionAnswer(
                      questionIndex,
                      answerIndex,
                      value,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remover resposta',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: question.answers.length <= 1
                      ? null
                      : () => controller.removeQuestionAnswer(
                          questionIndex,
                          answerIndex,
                        ),
                ),
              ],
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => controller.addQuestionAnswer(questionIndex),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar resposta'),
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DsPanel(
      tone: DsPanelTone.high,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Text(message),
    );
  }
}
