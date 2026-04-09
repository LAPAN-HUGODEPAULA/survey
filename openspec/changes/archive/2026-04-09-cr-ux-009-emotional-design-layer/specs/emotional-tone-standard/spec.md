## ADDED Requirements

### Requirement: Tone of Voice Profiles per Application
The system SHALL apply differentiated tone of voice profiles according to the context and the end user to reduce stress and increase trust.

#### Scenario: Tone for Patients (survey-patient)
- **WHEN** the user is performing a public screening
- **THEN** the system uses a calm, welcoming, and simple tone (e.g., "Estamos aqui para ajudar a entender melhor sua visão")
- **AND** avoids excessive technical or clinical terms

#### Scenario: Tone for Professionals (survey-frontend / clinical-narrative)
- **WHEN** the professional is performing an appointment
- **THEN** the system uses a clear, professional, and supportive tone (e.g., "Tudo pronto para iniciar a narrativa clínica")
- **AND** focuses on competence and efficiency

#### Scenario: Tone for Administrators (survey-builder)
- **WHEN** the administrator is editing a questionnaire
- **THEN** the system uses a precise, light, and low-noise tone (e.g., "Alterações salvas. O questionário está pronto para uso")

### Requirement: Effort Recognition in Completion Messages
Flow completion messages SHALL recognize the user's effort and the purpose of the task, instead of just confirming data receipt.

#### Scenario: Patient Completion
- **WHEN** the patient finishes the questionnaire
- **THEN** the system displays: "Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde"

#### Scenario: Professional Completion
- **WHEN** the professional finishes a session
- **THEN** the system displays: "Sessão concluída com sucesso. O registro clínico foi gerado e está pronto para sua revisão"
