## Why

Atualmente, o LAPAN Survey Platform apresenta comportamentos de formulário inconsistentes entre seus aplicativos (patient, frontend, builder, narrative). A falta de padrões para o tempo de validação, a exibição de erros (muitas vezes via snackbars genéricos) e a ausência de orientações prévias aumentam a carga cognitiva e a frustração do usuário ao preencher dados clínicos ou administrativos.

## What Changes

- Implementação de um modelo de validação padrão (preferencialmente no `blur` ou no `submit` para evitar erros hostis prematuros).
- Criação de componentes de resumo de erro (`Error Summary`) para formulários longos.
- Padronização de máscaras de entrada e textos de ajuda para campos comuns (CPF, Data, Telefone).
- Introdução de estados de "rascunho salvo" e preservação de dados em formulários administrativos.
- Substituição de snackbars por mensagens de erro em contexto (inline) ou resumos de seção.

## Capabilities

### New Capabilities
- `form-validation-standard`: Define as regras de quando e como as validações de campo devem ocorrer.
- `form-guidance-standard`: Define padrões para textos de ajuda, máscaras de entrada e resumos de erro.

### Modified Capabilities
- Nenhuma.

## Impact

- `packages/design_system_flutter`: Novos componentes para suporte a formulários (resumos, wrappers de validação).
- `apps/survey-patient`: Melhora na coleta de dados demográficos.
- `apps/survey-frontend`: Padronização de cadastros e configurações.
- `apps/survey-builder`: Melhora na experiência de edição de questionários densos.
- `apps/clinical-narrative`: Melhora nos inputs de diálogo e chat.
