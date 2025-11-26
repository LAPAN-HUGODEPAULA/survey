# Arquitetura do Sistema

## 1. Diagrama de Componentes

O diagrama abaixo ilustra a arquitetura geral do sistema, mostrando a interação entre os usuários, os frontends e o backend, incluindo os serviços desacoplados.

```mermaid
graph TD
    subgraph "Usuários"
        A[Paciente]
        B[Screener]
    end

    subgraph "Aplicações Frontend"
        C(survey_app)
    end

    subgraph "Backend"
        E[db (API FastAPI)]
        F[MongoDB]
        H{Serviços Assíncronos (E-mail)}
    end



    A -- "Fornece respostas" --> B
    B -- "Insere dados no" --> C

    C -- "1. Salva/Busca via API REST" --> E

    E -- "2. Armazena/Lê em" --> F
    E -- "3. Dispara tarefa para" --> H

    H -- "4. Envia notificação"
```

## 2. Descrição dos Componentes

### 2.1. `db` (Backend)

*   **Tecnologia**: Python com o framework FastAPI.
*   **Banco de Dados**: MongoDB, orquestrado via Docker Compose para facilitar a configuração do ambiente.
*   **Responsabilidades**:
    *   Expor endpoints REST para operações CRUD (Create, Read, Update, Delete) de `Surveys` (questionários) e `SurveyResponses` (respostas).
    *   Validar os dados recebidos utilizando modelos Pydantic, garantindo a integridade das informações que chegam ao banco de dados.
    *   Gerenciar a conexão com o MongoDB.
    *   Orquestrar tarefas assíncronas (ex: envio de e-mails de notificação) para não bloquear a resposta das requisições principais.
*   **Estrutura**:
    *   `main.py`: Ponto de entrada da aplicação FastAPI.
    *   `routers/`: Contém a lógica dos endpoints da API.
    *   `services/`: Isola lógicas de negócio complexas ou reutilizáveis (ex: `email_service`).
    *   `models/`: Define os modelos de dados (Pydantic) que representam as entidades do banco de dados.
    *   `config/`: Armazena as configurações da aplicação (conexão com banco, etc.).
    *   `migrate/`: Scripts para migração de dados (e.g., de JSON para MongoDB).

### 2.2. `survey_app` (Frontend Online)

*   **Tecnologia**: Flutter.
*   **Plataformas**: Compila para Web e Android.
*   **Responsabilidades**:
    *   Apresentar uma interface de usuário para o **Screener**.
    *   Buscar a lista de questionários disponíveis a partir da API do `db`.
    *   Renderizar o questionário selecionado, incluindo instruções, perguntas e opções de resposta.
    *   Coletar dados demográficos do paciente e as respostas para cada pergunta.
    *   Enviar o conjunto de respostas (`SurveyResponse`) para ser armazenado no backend via API em uma única requisição.

