# GEMINI.md

## 1. Visão Geral do Projeto

Este projeto é um sistema de análise clínica para coletar e analisar dados de pacientes. O sistema é operado por um **Screener** (profissional de saúde/pesquisador) que insere os dados de um **Paciente** através de uma aplicação. O objetivo é estruturar dados de anamnese e respostas a questionários padronizados para pesquisa e análise.

O repositório contém três subprojetos:

*   **`db`**: O backend da aplicação, desenvolvido em Python com FastAPI. É responsável por gerenciar a API REST e a interação com um banco de dados MongoDB. Armazena e recupera `surveys` (questionários) e `survey_responses` (respostas dos pacientes).
*   **`survey_app`**: A aplicação frontend principal, desenvolvida em Flutter (compatível com web e Android). Ela se comunica com o backend `db` para buscar questionários e salvar as respostas.
*   **`survey_app_local`**: Uma versão do frontend em Flutter que funciona de forma autônoma (offline). Ela lê os questionários de arquivos JSON locais e salva as respostas também em arquivos JSON, sem a necessidade de um backend ou conexão de rede.

## 2. Estrutura do Projeto e Dados

### `db` (Backend)
*   **Localização**: `/db`
*   **Tecnologia**: Python, FastAPI, MongoDB (via Docker).
*   **Ponto de Entrada**: `db/main.py`.
*   **Configuração**: `db/docker-compose.yml`.
*   **Modelos de Dados**: Definidos em `db/models/`, usam Pydantic para validação.
*   **Rotas da API**: Definidas em `db/routers/`.
*   **Migração**: O script `db/migrate/migrate_to_mongo.py` é usado para popular o banco de dados a partir dos arquivos JSON de `survey_app/assets/surveys`.

### `survey_app` & `survey_app_local` (Frontends)
*   **Localização**: `/survey_app` e `/survey_app_local`.
*   **Tecnologia**: Flutter.
*   **Ponto de Entrada**: `lib/main.dart` em ambos os projetos.
*   **Modelos de Dados**: `survey_app/lib/core/models/`
*   **Dependências**: Gerenciadas em `pubspec.yaml`.
*   **Dados Estáticos**:
    *   **Questionários**: `assets/surveys/*.json`. Usados pelo `survey_app_local` e pelo script de migração.
    *   **Respostas (local)**: `assets/survey_responses/*.json`. Onde o `survey_app_local` salva os resultados.
    *   **Dados da UI**: `assets/data/*.json` (e.g., `diagnoses.json`, `education_level.json`) fornecem dados para widgets como dropdowns e autocompletes.

## 3. Formato dos Dados Principais

### Estrutura do `Survey` (Questionário)
```json
{
  "_id": "string",
  "name": "string",
  "description": "string (HTML)",
  "questions": [
    {
      "id": "string",
      "questionText": "string",
      "answers": [
        { "id": "string", "text": "string", "value": "any" }
      ]
    }
  ]
}
```

### Estrutura da `SurveyResponse` (Resposta)
```json
{
  "_id": "string",
  "testDate": "string (ISO 8601)",
  "screener": "string",
  "screenerEmail": "string",
  "patientName": "string",
  "patientEmail": "string",
  "questions": [
    {
      "id": "number",
      "answer": "string"
    }
  ]
}
```

## 4. Comandos Comuns

### Iniciar Backend
'''bash
cd db
docker-compose up -d
'''

### Executar Migração de Dados
'''bash
cd db
python migrate/migrate_to_mongo.py
'''

### Executar App Flutter
'''bash
# Para a versão online
cd survey_app
flutter pub get
flutter run

# Para a versão offline
cd survey_app_local
flutter pub get
flutter run
'''