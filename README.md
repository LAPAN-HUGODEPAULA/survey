# Sistema de Survey para Análise Clínica

[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/HHerauto/survey/blob/main/README.md)

Este projeto é um sistema de análise clínica projetado para coletar e analisar dados de pacientes através de questionários padronizados. Ele é composto por um backend em Python (FastAPI) com MongoDB e um frontend em Flutter.

## Visão Geral

O sistema permite que um profissional de saúde (**Screener**) colete informações de um **Paciente** por meio de um aplicativo. As respostas são armazenadas para análise posterior.

O projeto é dividido em três componentes principais:

1.  **`db`**: O backend da aplicação, contendo a API REST e a configuração do banco de dados MongoDB.
2.  **`survey_app`**: O frontend principal em Flutter, que se conecta ao backend.
3.  **`survey_app_local`**: Uma versão offline do frontend que armazena os dados localmente em arquivos JSON.

## Documentação

Para uma visão completa da arquitetura, modelos de dados, e guias de configuração, consulte a **[documentação detalhada na pasta `docs`](./docs/index.md)**.

A documentação inclui:
*   [Visão Geral do Projeto](./docs/index.md)
*   [Arquitetura do Sistema](./docs/architecture.md)
*   [Modelo de Dados](./docs/data_model.md)
*   [Guia de Instalação](./docs/setup.md)

## Guia Rápido de Instalação

### Pré-requisitos
*   Git
*   Flutter SDK
*   Docker e Docker Compose

### Backend (`db`)
```bash
cd db
docker-compose up -d --build
```

### Frontend (`survey_app`)
```bash
cd survey_app
flutter pub get
flutter run
```

Para mais detalhes, siga o [Guia de Instalação completo](./docs/setup.md).
