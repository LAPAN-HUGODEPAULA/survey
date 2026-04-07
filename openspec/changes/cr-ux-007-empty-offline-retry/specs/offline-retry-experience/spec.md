## ADDED Requirements

### Requirement: Banner de Estado Offline
O sistema DEVE exibir um banner persistente quando a conexão com o servidor for perdida, explicando o que ainda funciona e se os dados locais estão seguros.

#### Scenario: Perda de conexão durante o uso
- **WHEN** a conexão com o servidor é interrompida
- **THEN** o sistema exibe no topo: "Você está offline. Suas alterações serão salvas localmente até a conexão voltar."
- **AND** utiliza o idioma Português Brasileiro (pt-BR).

### Requirement: Controle Global de Tentativa (Retry)
Falhas de rede ou de carregamento que sejam recuperáveis DEVEM oferecer um controle visível e consistente de "Tentar Novamente".

#### Scenario: Falha no carregamento do questionário
- **WHEN** um questionário não pode ser carregado devido a uma falha de rede
- **THEN** o sistema exibe a mensagem de erro acompanhada de um botão "Tentar Novamente" (Retry).
