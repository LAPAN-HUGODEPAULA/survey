## 1. Setup e Design System

- [ ] 1.1 Adicionar `mask_text_input_formatter` às dependências do `packages/design_system_flutter`.
- [ ] 1.2 Implementar o componente `DsMaskedTextField` com suporte a CPF, telefone, CEP e data.
- [ ] 1.3 Implementar o componente `DsFormSection` para agrupamento visual de campos.
- [ ] 1.4 Implementar o componente `DsErrorSummary` para exibir lista de erros no topo de formulários.

## 2. Padrões de Validação

- [ ] 2.1 Criar uma convenção/mixin no design system para lidar com o estado "touched" em campos de texto.
- [ ] 2.2 Atualizar widgets de entrada padrão para suportar a validação apenas no `blur` por padrão.

## 3. Implementação e Refatoração (Piloto)

- [ ] 3.1 Migrar o formulário de dados demográficos em `apps/survey-patient` para usar o novo padrão.
- [ ] 3.2 Implementar o `DsErrorSummary` no formulário de demográficos do paciente.
- [ ] 3.3 Validar máscaras de CPF e data no formulário migrado.

## 4. Verificação

- [ ] 4.1 Verificar se erros de "campo obrigatório" não aparecem durante a primeira digitação.
- [ ] 4.2 Verificar se o resumo de erros aparece corretamente ao clicar em "Continuar" com campos vazios.
- [ ] 4.3 Garantir que os dados brutos (sem máscara) são enviados corretamente para o backend.
- [ ] 4.4 Verificar se todos os rótulos, mensagens e avisos utilizam Português Brasileiro correto com acentuação (ex: "atenção", "formulário").
