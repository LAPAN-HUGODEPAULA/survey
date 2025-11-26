# Documentação do Sistema de Survey

## 1. Visão Geral

Este documento detalha a arquitetura, funcionalidades e estrutura de dados do projeto **Survey**, um sistema de análise clínica projetado para coletar e analisar dados de pacientes através de questionários padronizados.

O sistema foi desenvolvido para ser utilizado por um profissional de saúde ou pesquisador, doravante denominado **Screener**. O Screener é o responsável por conduzir a sessão de coleta de dados com o paciente, inserindo as informações no sistema. O paciente não possui acesso direto à aplicação.

## 2. Objetivos do Projeto

*   **Coleta de Dados Estruturada**: Fornecer uma interface intuitiva para o Screener coletar dados demográficos e respostas de pacientes a questionários de anamnese.
*   **Armazenamento Seguro**: Centralizar o armazenamento de questionários (surveys) e das respostas coletadas (survey responses) em um banco de dados robusto.
*   **Flexibilidade**: Permitir a operação em dois modos: um conectado a um backend (`survey_app`).
*   **Análise Clínica**: Facilitar a exportação e análise futura dos dados coletados para fins de pesquisa e prática clínica.

## 3. Componentes do Projeto

O repositório está organizado em três subprojetos principais:

1.  **`db`**: O backend da aplicação, desenvolvido em Python com FastAPI. É responsável por servir a API REST, interagir com o banco de dados MongoDB e gerenciar a lógica de negócio.
2.  **`survey_app`**: O frontend principal, desenvolvido em Flutter. Esta aplicação consome a API do projeto `db` para buscar questionários e salvar as respostas dos pacientes.

Para mais detalhes sobre a interação entre esses componentes, consulte a seção [Arquitetura](./architecture.md).
