## Why

Após a implementação de `cr-ux-001-standardize-feedback-severity-icons-and-message-structure` e `cr-ux-002-secure-entry-standards`, a plataforma já possui uma base compartilhada melhor para feedback, agrupamento visual e orientação em campos de autenticação. O problema restante não é mais a ausência total de componentes, mas a falta de um padrão único para comportamento de formulários.

Hoje, formulários semelhantes ainda validam em momentos diferentes, usam combinações distintas de mensagens inline e resumos, reaplicam formatadores localmente e preservam progresso de maneiras inconsistentes. Isso aumenta a carga cognitiva em `survey-patient`, `survey-frontend` e `survey-builder`, além de manter regras pouco previsíveis para formulários estruturados em `clinical-narrative`.

## What Changes

- Definição de um ciclo único de validação para a plataforma, baseado em validação adiada: sem erro prematuro durante a primeira digitação, validação no `blur` e na submissão, e revalidação apenas de campos já expostos como inválidos.
- Extensão dos componentes já padronizados no `design_system_flutter`, especialmente `DsValidationSummary`, `DsSection`, `DsFieldChrome` e as superfícies compartilhadas de campos, em vez de criar uma segunda família paralela de widgets.
- Consolidação de formatadores e orientações para campos estruturados (CPF, telefone, CEP e data) usando a abordagem já adotada com `TextInputFormatter` e normalização compartilhada, sem introduzir uma dependência de máscara sem necessidade comprovada.
- Padronização de resumos de erro, mensagens inline, marcadores de obrigatoriedade e textos de ajuda em formulários longos e estruturados.
- Introdução de estados visíveis de preservação de progresso e rascunho salvo em formulários administrativos longos do `survey-builder`.
- Remoção do uso de snackbars em momentos críticos de validação nos fluxos migrados, substituindo-os por mensagens em contexto e resumos de formulário.

## Capabilities

### New Capabilities
- `form-validation-standard`: Define as regras de quando e como as validações de campo devem ocorrer.
- `form-guidance-standard`: Define padrões para textos de ajuda, máscaras de entrada e resumos de erro.

### Modified Capabilities
- Nenhuma.

## Impact

- `packages/design_system_flutter`: Evolução dos componentes já existentes para formulários, validação, resumos e orientação de campo.
- `apps/survey-patient`: Consolidação do formulário demográfico com o ciclo padrão de validação e formatação compartilhada.
- `apps/survey-frontend`: Consolidação dos formulários demográficos, de autenticação herdada e de configurações para o mesmo modelo de orientação e erro.
- `apps/survey-builder`: Introdução de resumo de erros, seções consistentes e preservação de rascunho nos formulários administrativos longos migrados.
- `apps/clinical-narrative`: Adoção do padrão em formulários estruturados compartilhados; entradas conversacionais livres ficam explicitamente fora do escopo desta mudança.
