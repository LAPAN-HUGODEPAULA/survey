## 1. Preparação

- [x] 1.1 Identificar os arquivos exatos de `DsProfessionalSignInCard` e `DsProfessionalSignUpCard` em `packages/design_system_flutter/lib/components/auth/`.
- [x] 1.2 Criar um teste de unidade básico ou script de reprodução para verificar o estado inicial (obscureText fixo).

## 2. Implementação do Design System

- [x] 2.1 Refatorar `DsProfessionalSignInCard` para ser um `StatefulWidget` (se ainda não for) e adicionar controle de visibilidade da senha.
- [x] 2.2 Adicionar `IconButton` como `suffixIcon` no campo de senha do login com ícones `visibility_off_outlined` e `visibility_outlined`.
- [x] 2.3 Refatorar `DsProfessionalSignUpCard` para ser um `StatefulWidget` e adicionar controle de visibilidade da senha.
- [x] 2.4 Adicionar `IconButton` como `suffixIcon` no campo de senha do registro.
- [x] 2.5 Adicionar texto de ajuda (Helper Text) com requisitos de senha ("Use pelo menos 8 caracteres") no campo de senha do registro.

## 3. Verificação e Testes

- [x] 3.1 Verificar funcionalidade no `survey-frontend`: Login profissional deve permitir mostrar/ocultar senha.
- [x] 3.2 Verificar funcionalidade no `survey-frontend`: Registro profissional deve permitir mostrar/ocultar senha e exibir requisitos.
- [x] 3.3 Validar que a troca de visibilidade preserva a posição do cursor.
- [x] 3.4 Validar que colagem (paste) e gerenciadores de senha funcionam normalmente nos campos atualizados.
