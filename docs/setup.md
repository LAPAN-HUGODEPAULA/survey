# Guia de Instalação e Configuração

Este guia fornece as instruções para configurar o ambiente de desenvolvimento e executar todos os componentes do projeto.

## 1. Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas em seu sistema:

*   **Git**: Para clonar o repositório.
*   **Flutter SDK**: Para executar as aplicações `survey_app` e `survey_app_local`. (Consulte a [documentação oficial do Flutter](https://flutter.dev/docs/get-started/install) para instruções de instalação).
*   **Docker e Docker Compose**: Para executar o banco de dados MongoDB e o backend. (Consulte a [documentação oficial do Docker](https://docs.docker.com/get-docker/)).
*   **Python**: Para os scripts de migração e o backend.

## 2. Clonando o Repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd survey
```

## 3. Configurando e Executando o Backend (`db`)

O backend e o banco de dados são gerenciados com Docker.

1.  **Navegue até o diretório `db`:**
    ```bash
    cd db
    ```

2.  **Inicie os contêineres Docker:**
    Este comando irá construir e iniciar o serviço do MongoDB e o serviço da API FastAPI em segundo plano.
    ```bash
    docker-compose up -d --build
    ```

3.  **Migre os dados iniciais (Opcional):**
    O projeto inclui um script para popular o MongoDB com os questionários de exemplo localizados em `survey_app/assets/surveys`.
    ```bash
    python migrate/migrate_to_mongo.py
    ```
    *Nota: Pode ser necessário instalar dependências Python antes, como `pymongo`.*

## 4. Configurando e Executando o Frontend (`survey_app`)

### 4.1. `survey_app` (Modo Online)

1.  **Navegue até o diretório `survey_app`:**
    ```bash
    cd survey_app
    ```

2.  **Instale as dependências do Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Execute a aplicação:**
    Você pode escolher a plataforma de destino (ex: Chrome para web, ou um emulador Android).
    ```bash
    # Para executar na web
    flutter run -d chrome

    # Para executar em um dispositivo Android conectado
    flutter run
    ```

### 4.2. `survey_app_local` (Modo Offline)

O processo é idêntico ao do `survey_app`, mas no diretório correspondente.

1.  **Navegue até o diretório `survey_app_local`:**
    ```bash
    cd survey_app_local
    ```

2.  **Instale as dependências do Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Execute a aplicação:**
    ```bash
    flutter run
    ```
