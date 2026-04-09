## Context

Atualmente, os componentes de autenticação compartilhados no `packages/design_system_flutter` (`DsProfessionalSignInCard` e `DsProfessionalSignUpCard`) utilizam campos de texto de senha com `obscureText: true` fixo, sem oferecer ao usuário a possibilidade de conferir o que foi digitado. Isso gera fricção e aumenta a taxa de erro no login e registro.

## Goals / Non-Goals

**Goals:**
- Implementar um controle de "mostrar/ocultar senha" consistente em todos os formulários de autenticação profissional.
- Melhorar a acessibilidade e a usabilidade dos campos de senha seguindo padrões modernos de UX.
- Garantir que a troca de visibilidade seja fluida e não cause perda de foco ou posição do cursor.

**Non-Goals:**
- Alterar a lógica de autenticação no backend.
- Implementar um sistema de gerenciamento de senhas completo (apenas usabilidade do campo).
- Alterar campos de senha em áreas não relacionadas à autenticação profissional (ex: formulários administrativos internos que não usem o design system).

## Decisions

### 1. Adição de Toggle de Visibilidade nos Auth Cards
- **Rationale**: Adicionar o controle diretamente nos cards de autenticação (`DsProfessionalSignInCard` e `DsProfessionalSignUpCard`) garante que todos os apps que utilizam esses componentes ganhem a funcionalidade automaticamente.
- **Implementation**: Utilizar o parâmetro `suffixIcon` do `InputDecoration` do `TextFormField`. O estado de visibilidade será controlado por uma variável `bool` local dentro do widget.
- **Alternatives**: Criar um novo widget `DsPasswordField`. Decidimos por atualizar os cards existentes para manter a simplicidade e garantir a adoção imediata sem refatoração nos apps.

### 2. Uso de Ícones Outlined
- **Rationale**: Seguir o padrão visual do `design_system_flutter` que prefere estilos "outlined".
- **Icons**: `Icons.visibility_off_outlined` (oculto) e `Icons.visibility_outlined` (visível).

### 3. Preservação do Cursor
- **Rationale**: A experiência do usuário é prejudicada se o cursor voltar ao início do campo após o toggle.
- **Implementation**: Ao alternar o estado de visibilidade, garantir que o `TextEditingController` mantenha a seleção atual. O Flutter geralmente lida bem com isso, mas verificaremos se o `selection` precisa ser reatribuído manualmente.

## Risks / Trade-offs

- **[Risco]** Quebra de layout em telas muito pequenas devido ao espaço ocupado pelo ícone. → **Mitigação**: O design system já prevê responsividade e o ícone de sufixo é padrão do Material Design.
- **[Trade-off]** Aumento leve na complexidade de estado dos widgets de card. → **Mitigação**: O estado é simples (booleano) e encapsulado, não afetando a lógica externa.
