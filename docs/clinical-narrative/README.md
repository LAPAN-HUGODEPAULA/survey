# Clinical Narrative (Guia de Uso)

Este guia descreve como utilizar o aplicativo Clinical Narrative da plataforma LAPAN Survey para conduzir conversas clínicas, registrar informações e gerar documentos clínicos.

## Pré-requisitos

- Serviços necessários em execução: `mongodb`, `survey-backend` e `clinical-narrative`.
- Para recursos de análise/assistência clínica, o `clinical-writer-api` deve estar disponível e configurado no backend.
- Navegador moderno com permissão de microfone (para captura de voz).

## Como iniciar (ambiente local)

A partir da raiz do repositório, suba os serviços necessários:

```bash
./tools/scripts/compose_local.sh up -d mongodb survey-backend clinical-writer-api clinical-narrative
```

A aplicação ficará disponível em `http://localhost:8082`.

## Fluxo principal do usuário

1. Abra o aplicativo e preencha as informações do paciente.
2. Avance para a conversa clínica.
3. Registre a conversa digitando mensagens ou usando a captura de voz.
4. Acompanhe sugestões, alertas e hipóteses (quando disponíveis).
5. Gere documentos clínicos a partir da conversa e/ou narrativa.
6. Pré-visualize e exporte o documento (PDF/Impressão).
7. Encerre a consulta para concluir a sessão.

## Captura de voz

- Ative o modo de voz no campo de mensagem.
- Clique em **Iniciar** para gravar e **Parar** para finalizar.
- Use a pré-visualização ao vivo para revisar o conteúdo.
- Envie para transcrição para inserir o texto no chat.

## Geração de documentos

- Clique em **Gerar documento**.
- Selecione o **tipo de documento** e um **modelo** (template).
- Ajuste **título** e **conteúdo** se necessário.
- Use **Pré-visualizar** para conferir o resultado.
- Use **Exportar PDF/Imprimir** para gerar a saída final.

## Observações importantes

- A sessão fica indisponível para edição quando marcada como concluída.
- Em modo offline, o envio de mensagens e geração de documentos podem ficar bloqueados.
- A captura de voz funciona apenas em navegadores com suporte e permissões adequadas.

## Suporte e referência

- Para visão geral do projeto, consulte `docs/overview.md`.
- Para detalhes técnicos do backend, consulte `docs/software-design.md` e `docs/technical-specification.md`.
