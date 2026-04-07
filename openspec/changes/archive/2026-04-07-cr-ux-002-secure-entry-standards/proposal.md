## Why

A senha oculta sem opção de exibição aumenta a carga cognitiva e a frustração do usuário, dificultando a correção de erros de digitação e a confiança no login. O padrão WCAG (SC 3.3.8 Accessible Authentication) recomenda o controle de visibilidade da senha como uma forma de reduzir a carga cognitiva e melhorar a usabilidade geral da autenticação.

## What Changes

- Adição de um controle de revelação de senha (ícone de olho) em todos os campos de senha dos componentes de autenticação compartilhados.
- Garantia de que a troca de visibilidade preserve a posição do cursor e o conteúdo já digitado.
- Permissão explícita de colagem e uso de gerenciadores de senha/autofill em todos os campos de autenticação.
- Exibição clara dos requisitos de senha antes da submissão do formulário.

## Capabilities

### New Capabilities
- `auth-secure-entry-usability`: Define os padrões de interação e usabilidade para campos de entrada segura (senhas), incluindo controles de visibilidade, suporte a acessibilidade e orientações prévias de validação.

### Modified Capabilities
- Nenhuma.

## Impact

- `packages/design_system_flutter`: Atualização dos componentes `DsProfessionalSignInCard` e `DsProfessionalSignUpCard` (ou seus sub-widgets de campo de texto).
- `apps/survey-frontend`: Login e registro profissional serão atualizados automaticamente via design system.
- `apps/clinical-narrative`: Fluxos de autenticação que utilizam os componentes compartilhados.
