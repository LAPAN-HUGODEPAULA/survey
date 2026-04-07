## MODIFIED Requirements

### Requirement: Microphone Error Handling
O sistema DEVE mapear erros comuns de microfone para mensagens amigáveis em Português Brasileiro (pt-BR) e oferecer caminhos de recuperação.

#### Scenario: Permission denied
- **WHEN** o navegador retorna um erro de permissão de microfone
- **THEN** o sistema exibe orientações em pt-BR, link para as configurações do navegador e habilita a entrada de texto alternativa.

#### Scenario: Microphone unavailable
- **WHEN** nenhum dispositivo de áudio é detectado
- **THEN** o sistema informa o problema em pt-BR e sugere "Tentar Novamente".

### Requirement: Transcription Error Handling
O sistema DEVE tratar falhas de upload e transcrição com retentativas e uma alternativa de edição manual.

#### Scenario: Upload failure
- **WHEN** o upload do áudio falha devido a erro de rede
- **THEN** o sistema tenta novamente conforme a política configurada, exibe o progresso e oferece um botão de "Tentar Novamente" manual em pt-BR.

#### Scenario: Transcription failure
- **WHEN** o servidor não consegue transcrever o áudio
- **THEN** o sistema permite que o usuário escreva manualmente as notas da sessão clínica e captura o motivo da falha.

## ADDED Requirements

### Requirement: Mensagens de Erro Legíveis por Humanos
O sistema DEVE substituir strings de erro técnico ou códigos de exceção (ex: "HTTP 500", "ConnectionTimeout") por explicações amigáveis em Português Brasileiro que descrevam o problema e o que o usuário pode fazer.

#### Scenario: Erro de servidor interno
- **WHEN** ocorre um erro 500 no backend
- **THEN** o sistema exibe: "Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes."
- **AND** fornece o botão "Tentar Novamente".
