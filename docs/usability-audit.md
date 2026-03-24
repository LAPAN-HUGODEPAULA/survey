# Avaliação de Usabilidade e Acessibilidade (WCAG 2.1 AA)

Data: 2026-02-26

## Escopo

Aplicações analisadas:
- `survey-frontend`
- `survey-patient`
- `clinical-narrative`
- `survey-builder`

Itens solicitados:
- Unificação de tema via `packages/design_system_flutter`.
- Títulos (barra do navegador) e ícones padronizados com marca LAPAN.
- Interface 100% PT-BR.
- Validação de acessibilidade conforme WCAG 2.1 AA.
- Registro de erros de usabilidade e propostas de solução.

## Ações Executadas

- Tema unificado em `packages/design_system_flutter/lib/theme/app_theme.dart`.
- Títulos do navegador definidos em PT-BR (MaterialApp + `web/index.html`).
- Manifestos PWA atualizados (nome, descrição e cores em PT-BR).
- Ícones PWA e favicon atualizados com o ícone LAPAN em todas as apps.
- Ajuste de contraste do tema (botões e AppBar) para atender WCAG AA.
- Ajuste de mensagens em PT-BR onde havia inglês em exceções.

## Validação de Acessibilidade (WCAG 2.1 AA)

### Status Atual
- **Contraste de texto**: ajustado no tema para eliminar branco sobre laranja (razão 2.15:1).
  - Agora texto preto sobre laranja atende AA.
- **Rótulos de inputs**: campos principais usam `labelText`.
- **Botões com ícone**: botões com ícone possuem `tooltip` (nome acessível).
- **Foco e navegação por teclado**: suporte básico do Flutter; algumas telas usam ordenação de foco.

### Pendências para validação final
- Teste de contraste real em componentes específicos de cada tela (por exemplo, chips, badges, cards).
- Verificação de estados de foco visíveis em todos os componentes interativos.
- Verificação de tamanho mínimo de toque em dispositivos móveis.
- Auditoria com ferramentas automatizadas (Lighthouse/Axe) em ambiente web.

## Erros de Usabilidade Encontrados e Propostas

### 1. Padrão de interação inconsistente entre aplicativos
- **Impacto**: usuários que alternam entre apps precisam reaprender navegação e ações principais.
- **Proposta**:
  - Definir um padrão de layout compartilhado (ex.: `MainLayout` no design system).
  - Unificar posicionamento de ações primárias (ex.: botão principal sempre à direita).
  - Criar um guideline de navegação e fluxo (login, cadastro, início, finalização).

### 2. Títulos genéricos no navegador
- **Impacto**: dificulta identificação em múltiplas abas.
- **Proposta**: títulos específicos por app (já corrigido).

### 3. Contraste insuficiente em componentes principais
- **Impacto**: falha de legibilidade e não conformidade WCAG AA.
- **Proposta**: ajustar tema para texto preto sobre laranja (já corrigido).

### 4. Ícones padrão do Flutter nos aplicativos
- **Impacto**: perda de identidade da marca e percepção de produto inacabado.
- **Proposta**: padronização com ícone LAPAN (já corrigido para web).

### 5. Linguagem inconsistente em exceções e mensagens técnicas
- **Impacto**: mensagens em inglês podem aparecer ao usuário final.
- **Proposta**: traduzir mensagens de erro e exceções (corrigido nos repositórios de survey).

## Recomendações de Próximos Passos

1. Rodar auditorias de acessibilidade (Lighthouse/Axe) em cada app web.
2. Padronizar layout e navegação com um componente do design system.
3. Definir guideline de microcopy (títulos, CTAs, mensagens de erro).
4. Incluir testes de acessibilidade (semântica, foco, contraste) em CI.
