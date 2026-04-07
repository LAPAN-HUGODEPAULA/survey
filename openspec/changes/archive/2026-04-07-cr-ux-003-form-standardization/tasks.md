## 1. Setup e Design System

- [x] 1.1 Auditar e documentar os componentes compartilhados que serão estendidos neste change (`DsValidationSummary`, `DsSection`, `DsFieldChrome`, `DsPatientIdentitySection` e campos equivalentes).
- [x] 1.2 Implementar no `design_system_flutter` o ciclo único de validação adiada para formulários estruturados.
- [x] 1.3 Extrair ou consolidar formatadores, normalizadores e helpers compartilhados para CPF, telefone, CEP e data sem introduzir nova dependência de máscara.
- [x] 1.4 Evoluir `DsValidationSummary` para o papel de resumo canônico de formulário, com suporte opcional a labels de campo e navegação para erros quando aplicável.
- [x] 1.5 Evoluir as superfícies compartilhadas de campo para suportar estado `pristine/touched/submitted`, textos de ajuda consistentes e marcadores de obrigatoriedade.

## 2. Padrões de Validação

- [x] 2.1 Definir e aplicar a convenção única de validação: sem erro na primeira digitação, validação no `blur`, validação completa no `submit` e revalidação apenas de campos já expostos como inválidos.
- [x] 2.2 Atualizar os widgets compartilhados de entrada e os formulários piloto para usar essa convenção, removendo usos inconsistentes de `AutovalidateMode.onUserInteraction` onde houver ruído prematuro.
- [x] 2.3 Padronizar a regra de uso entre erro inline, resumo de formulário e feedback de seção nos fluxos migrados.

## 3. Implementação e Refatoração (Piloto)

- [x] 3.1 Migrar `DsPatientIdentitySection` e `DsSurveyDemographicsSection` para o ciclo unificado de validação e para os formatadores compartilhados.
- [x] 3.2 Atualizar o formulário demográfico de `apps/survey-patient` para usar o padrão canônico de validação, resumo e orientação de campos.
- [x] 3.3 Atualizar o formulário demográfico de `apps/survey-frontend` para o mesmo padrão, preservando o comportamento já padronizado de feedback em contexto.
- [x] 3.4 Garantir que erros agrupados (por exemplo, seleções obrigatórias fora de `TextFormField`) entrem no `DsValidationSummary` e tenham tratamento inline coerente.

## 4. Builder e Preservação de Progresso

- [x] 4.1 Aplicar `DsSection`, resumo de validação e orientação consistente aos formulários administrativos longos do `survey-builder` incluídos neste change.
- [x] 4.2 Implementar preservação de rascunho e estados visíveis de progresso salvo para os formulários administrativos longos migrados.
- [x] 4.3 Remover snackbars em momentos críticos de validação dos formulários administrativos migrados, substituindo-os por feedback em contexto.

## 5. Clinical Narrative e Verificação Final

- [x] 5.1 Verificar e ajustar os formulários estruturados compartilhados ou equivalentes em `clinical-narrative` para que herdem o mesmo ciclo de validação, orientação e resumo de erros.
- [x] 5.2 Confirmar explicitamente que o composer do chat e entradas conversacionais livres permanecem fora do escopo deste change.
- [x] 5.3 Verificar se erros de "campo obrigatório" não aparecem durante a primeira digitação nos formulários migrados.
- [x] 5.4 Verificar se o resumo de erros aparece corretamente ao submeter formulários com múltiplas falhas.
- [x] 5.5 Garantir que os dados enviados ao backend permaneçam normalizados corretamente para os campos estruturados.
- [x] 5.6 Verificar se todos os rótulos, mensagens e avisos utilizam Português Brasileiro correto com acentuação (ex: "atenção", "formulário", "obrigatório").
