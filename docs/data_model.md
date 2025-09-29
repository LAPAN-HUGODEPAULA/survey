# Modelo e Formato de Dados

O sistema utiliza uma estrutura de dados bem definida, majoritariamente em formato JSON, para garantir a consistência entre o frontend, o backend e os arquivos de armazenamento.

## 1. Dados da Aplicação

Estes arquivos servem como fonte de dados para componentes de UI, como dropdowns e autocompletes. Estão localizados em `survey_app/assets/data/`.

*   **`diagnoses.json`**: Lista de transtornos mentais reconhecidos pelo sistema.
*   **`education_level.json`**: Lista de níveis de escolaridade.
*   **`professions.json`**: Lista de profissões para referência em campos de autocompletar.

## 2. Estrutura do Questionário (`Survey`)

Os questionários são definidos em arquivos JSON na pasta `assets/surveys`. Esta estrutura é usada tanto pelo `survey_app_local` quanto pelo script de migração para o MongoDB. Note que o identificador principal é `_id`.

```json
{
  "_id": "string",
  "name": "string",
  "description": "string (HTML)",
  "creatorName": "string",
  "creatorContact": "string",
  "createdAt": "string (ISO 8601)",
  "modifiedAt": "string (ISO 8601)",
  "instructions": {
    "preamble": "string (HTML)",
    "questionText": "string",
    "answers": [
      {
        "id": "string",
        "text": "string",
        "value": "any"
      }
    ]
  },
  "questions": [
    {
      "id": "string",
      "questionText": "string",
      "answers": [
        {
          "id": "string",
          "text": "string",
          "value": "any"
        }
      ]
    }
  ],
  "finalNotes": "string (HTML)"
}
```

## 3. Estrutura da Resposta (`SurveyResponse`)

Quando um paciente completa um questionário, as respostas são agregadas em um objeto com a seguinte estrutura. Este objeto é o que é salvo em um arquivo JSON (no `survey_app_local`) ou enviado para a API do `db`.

A estrutura aninha os dados do `Screener`, do `Patient` e os dados clínicos.

```json
{
  "_id": "string",
  "creatorName": "string",
  "creatorContact": "string",
  "testDate": "string (ISO 8601)",
  "screener": "string",
  "screenerEmail": "string",
  "patientName": "string",
  "patientEmail": "string",
  "patientBirthDate": "string",
  "patientGender": "string",
  "patientEthnicity": "string",
  "patientEducationLevel": "string",
  "patientProfession": "string",
  "patientMedication": "string",
  "patientDiagnoses": ["string"],
  "clinicalData": {
    "data": "any"
  },
  "questions": [
    {
      "id": "number",
      "answer": "string"
    }
  ]
}
```