# Modelo e Formato de Dados

O sistema utiliza uma estrutura de dados bem definida, majoritariamente em formato JSON, para garantir a consistência entre o frontend, o backend e os arquivos de armazenamento.

## 1. Dados da Aplicação

Estes arquivos servem como fonte de dados para componentes de UI, como dropdowns e autocompletes. Estão localizados em `survey_app/assets/data/`.

*   **`diagnoses.json`**: Lista de transtornos mentais reconhecidos pelo sistema.
*   **`education_level.json`**: Lista de níveis de escolaridade.
*   **`professions.json`**: Lista de profissões para referência em campos de autocompletar.

## 2. Estrutura do Questionário (`Survey`)

Os questionários são definidos em arquivos JSON na pasta `assets/surveys`. Esta estrutura é usada pelo script de migração para o MongoDB. Note que o identificador principal é `_id`.

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

Quando um paciente completa um questionário, as respostas são agregadas em um objeto com a seguinte estrutura. Este objeto é o que é enviado para a API do `db`.

A estrutura aninha os dados do `Patient` dentro do documento `SurveyResponse`.

```json
{
  "_id": "string (ObjectID)",
  "surveyId": "string",
  "creatorName": "string",
  "creatorContact": "string",
  "testDate": "string (ISO 8601)",
  "screenerName": "string",
  "screenerEmail": "string",
  "patient": {
    "name": "string",
    "email": "string",
    "birthDate": "string",
    "gender": "string",
    "ethnicity": "string",
    "educationLevel": "string",
    "profession": "string",
    "medication": ["string"],
    "diagnoses": ["string"],
    "family_history": "string",
    "social_history": "string",
    "medical_history": "string",
    "medication_history": "string"
  },
  "answers": [
    {
      "id": "string",
      "answer": "string"
    }
  ]
}
```

## 4. Relacionamento de Dados
### Paciente e Respostas (Patient & SurveyResponse)
O modelo de dados do sistema é intencionalmente denormalizado em relação aos dados do paciente. Em vez de manter uma coleção separada de pacientes e referenciá-los nas respostas, os dados completos do paciente são **embutidos (embedded)** em cada documento `SurveyResponse`.
#### Vantagens desta Abordagem:
- **Simplicidade**: Facilita a criação e a leitura de uma resposta de questionário, pois todos os dados necessários estão contidos em um único documento.
- **Histórico do Paciente**: Permite que o estado dos dados demográficos e clínicos do paciente seja 'congelado' no momento de cada avaliação. Isso é útil para análises longitudinais, onde é importante saber quais eram os dados do paciente em cada ponto do tempo.
#### Implicações:
- **Múltiplas Respostas**: Um mesmo paciente pode ter múltiplas entradas na coleção `survey_responses`, uma para cada questionário respondido. Não há uma chave primária única para o paciente em si.
- **Atualização de Dados**: Se os dados de um paciente precisarem ser corrigidos, a correção teria que ser aplicada em cada um dos seus documentos de resposta, ou apenas nos futuros.