# Guia de Instalação e Configuração

Este guia fornece as instruções para configurar o ambiente de desenvolvimento e executar todos os componentes do projeto: Backend, Frontend (Screener App) e Patient App.

## 1. Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas em seu sistema:

- **Git**: Para clonar o repositório.
- **Flutter SDK**: Para executar as aplicações `frontend` e `patient_app`. (Consulte a [documentação oficial do Flutter](https://flutter.dev/docs/get-started/install) para instruções de instalação).
- **Docker e Docker Compose**: Para executar o banco de dados MongoDB, o backend e as aplicações web em um ambiente local. (Consulte a [documentação oficial do Docker](https://docs.docker.com/get-docker/)).
- **Python**: Para os scripts de migração e o backend.
- **Firebase CLI**: Para fazer o deploy do backend e testar localmente com o emulador. (Consulte a [documentação oficial do Firebase](https://firebase.google.com/docs/cli)).

## 2. Clonando o Repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd survey
```

## 3. Configurando e Executando com Docker (Recomendado)

O projeto utiliza Docker Compose para orquestrar todos os serviços: Backend, MongoDB, Frontend (Screener) e Patient App.

### 3.1. Configuração

1.  **Variáveis de Ambiente**:
    Copie o arquivo de exemplo do backend para a raiz.

    ```bash
    cp backend/.env .env
    ```

    Você também pode configurar variáveis específicas para o `patient_app` exportando-as antes de rodar o docker-compose:

    ```bash
    export DEFAULT_SCREENER_NAME="Dr. Exemplo"
    export DEFAULT_SCREENER_CONTACT="contato@exemplo.com"
    ```

### 3.2. Execução

Para iniciar todo o ambiente (Backend + Banco + Apps Web):

```bash
docker-compose up -d --build
```

Isso irá iniciar os seguintes serviços:

- **Frontend (Screener App)**: http://localhost:80
- **Patient App**: http://localhost:8081
- **Backend API**: http://localhost:8000/docs
- **MongoDB**: porta 27017

## 4. Executando Individualmente (Desenvolvimento)

### 4.1. Backend

Você pode rodar o backend localmente com Python ou via Docker.

**Via Docker (apenas backend e banco):**

```bash
docker-compose up -d backend mongodb
```

**Via Python (local):**

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 4.2. Frontend (Screener App)

O `frontend` é a aplicação administrativa para os Screeners.

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 4.3. Patient App

O `patient_app` é a versão simplificada para os pacientes.

```bash
cd patient_app
flutter pub get
# Para rodar com configurações padrão
flutter run -d chrome

# Para rodar com configurações personalizadas
flutter run -d chrome --dart-define=DEFAULT_SCREENER_NAME="Dr. Teste" --dart-define=DEFAULT_SCREENER_CONTACT="teste@email.com"
```

## 5. Deploy no Firebase

O backend está configurado para ser implantado como Firebase Functions.

1.  **Configuração do Firebase:**
    Certifique-se de estar logado no Firebase CLI (`firebase login`) e ter o projeto configurado.

2.  **Deploy do Backend:**
    O código para deploy no Firebase está na raiz, utilizando o `backend` como source.

    ```bash
    firebase deploy --only functions
    ```

    _Nota: O arquivo `firebase.json` na raiz configura o redirecionamento das funções._

## 6. Migração de Dados

Para popular o banco de dados com os questionários iniciais:

```bash
# Executar script de migração (requer dependências do backend instaladas)
python backend/migrate/migrate_to_mongo.py
```
