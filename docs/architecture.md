# Arquitetura do Sistema

## 1. Diagrama de Componentes

O diagrama abaixo ilustra a arquitetura geral do sistema, mostrando a interação entre os usuários, os frontends e o backend.

```mermaid
graph TD
    subgraph "Usuários"
        A[Paciente]
        B[Screener]
    end

    subgraph "Aplicações Frontend"
        C(survey_app)
        D(survey_app_local)
    end

    subgraph "Backend"
        E[db (API FastAPI)]
        F[MongoDB]
    end

    subgraph "Armazenamento Local"
        G([Arquivos JSON])
    end

    A -- "Fornece respostas" --> B
    B -- "Insere dados no" --> C
    B -- "Pode usar alternativamente" --> D

    C -- "Salva/Busca via API REST" --> E
    D -- "Salva/Busca em" --> G

    E -- "Armazena/Lê em" --> F
```

## 2. Descrição dos Componentes

### 2.1. `db` (Backend)

*   **Tecnologia**: Python com o framework FastAPI.
*   **Banco de Dados**: MongoDB, orquestrado via Docker Compose para facilitar a configuração do ambiente.
*   **Responsabilidades**:
    *   Expor endpoints REST para operações CRUD (Create, Read, Update, Delete) de `Surveys` (questionários) e `SurveyResponses` (respostas).
    *   Validar os dados recebidos utilizando modelos Pydantic, garantindo a integridade das informações que chegam ao banco de dados.
    *   Gerenciar a conexão com o MongoDB.
*   **Estrutura**:
    *   `main.py`: Ponto de entrada da aplicação FastAPI.
    *   `routers/`: Contém a lógica dos endpoints da API.
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
    *   Enviar o conjunto de respostas (`SurveyResponse`) para ser armazenado no backend via API.

### 2.3. `survey_app_local` (Frontend Offline)

*   **Tecnologia**: Flutter.
*   **Funcionalidade**: É uma variante do `survey_app` que não depende de uma conexão de rede.
*   **Responsabilidades**:
    *   Ler os questionários diretamente de arquivos JSON localizados na pasta `assets/surveys`.
    *   Apresentar a interface de coleta de dados para o Screener.
    *   Salvar as respostas do paciente em um novo arquivo JSON na pasta `assets/survey_responses`.
*   **Caso de Uso**: Ideal para desenvolvimento, demonstrações ou para uso em campo onde a conectividade com a internet não é garantida.
