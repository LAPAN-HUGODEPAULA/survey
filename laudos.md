# **Arquiteturas Modernas para Sistemas de Apoio ao Diagnóstico e Documentação Clínica Automatizada: Um Estudo sobre Orquestração de Agentes, Skills Modulares e Adaptação de Parâmetros de Baixo Rank**

O avanço na integração de modelos de linguagem de grande escala (LLMs) em sistemas de saúde brasileiros, especificamente no contexto de distúrbios do neurodesenvolvimento e avaliações de hipersensibilidade visual, marca uma transição de simples ferramentas de transcrição para agentes clínicos autônomos e stateful.1 O projeto LAPAN, centrado na digitalização e validação da escala Cardiff Hypersensitivity Scale (CHYPS-Br), exemplifica a necessidade de uma infraestrutura técnica que suporte múltiplas camadas de interpretação diagnóstica e diversos perfis de saída.2 A transição de prompts monolíticos para arquiteturas modulares não é apenas uma escolha de eficiência computacional, mas um imperativo de segurança clínica e conformidade regulatória com a Lei Geral de Proteção de Dados (LGPD).2

## **Paradigmas de Orquestração e Gestão de Estado em Sistemas Multiagentes**

A implementação de um sistema que processe diversos questionários e gere laudos personalizados para médicos, escolas e pacientes exige uma transição do modelo de "solicitação-resposta" para o de "grafo de estados".4 O uso do LangGraph, uma extensão do ecossistema LangChain, permite a criação de fluxos de trabalho cíclicos onde cada nó representa uma etapa cognitiva específica: interpretação dos escores, seleção de persona e validação de fatos.4

### **Arquitetura de Grafos de Estado para Laudos Clínicos**

Diferente de sistemas lineares, um grafo de estado permite que a lógica de interpretação diagnóstica seja isolada da lógica de formatação de texto.6 Em um fluxo de apoio ao diagnóstico, o estado compartilhado atua como um "quadro branco" colaborativo onde as informações são agregadas e refinadas de forma incremental.8

| Componente de Grafo | Função no Sistema de Laudos | Benefício Técnico |
| :---- | :---- | :---- |
| **Nó de Classificação** | Identifica o tipo de questionário (ex: CHYPS-V) e os perfis de laudo solicitados. | Garante roteamento dinâmico e evita sobrecarga de contexto.10 |
| **Nó de Interpretação** | Aplica a lógica clínica específica ao escore bruto do paciente. | Centraliza o conhecimento do domínio clínico de forma modular.2 |
| **Nó de Geração (Perfil)** | Transforma a interpretação clínica no tom e estrutura do destinatário. | Permite paralelismo na geração de múltiplos laudos simultâneos.6 |
| **Nó de Reflexão** | Realiza a autocrítica do laudo gerado contra os dados brutos do questionário. | Reduz drasticamente a incidência de alucinações extrínsecas.14 |

A evidência sugere que a separação entre análise (entender os dados) e extração estruturada (converter raciocínio em laudo validado) torna o sistema significativamente mais robusto.11 Ao evitar que um único "mega-agente" tente processar a interpretação clínica e a formatação para a escola simultaneamente, reduz-se a probabilidade de o modelo omitir detalhes críticos ou misturar terminologias técnicas com linguagem acessível.11

### **Persistência de Threads e Intervenção Humana (Human-in-the-Loop)**

A natureza sensível dos diagnósticos de neurodesenvolvimento exige mecanismos de persistência que permitam a auditoria e a revisão humana.2 O uso de checkpointers no LangGraph — utilizando backends como PostgreSQL ou MongoDB — garante que o estado da execução seja salvo a cada "super-step".8 Isso permite que um médico inicie a narrativa clínica pela manhã e retorne para revisar e aprovar o laudo gerado pela IA no período da tarde, sem perda de contexto ou necessidade de reprocessamento.2

| Estratégia de Estado | Implementação Sugerida | Vantagem para o LAPAN |
| :---- | :---- | :---- |
| **Checkpointers Duráveis** | Armazenamento em MongoDB/PostgreSQL. | Resiliência contra falhas de servidor em sessões longas.8 |
| **Threads Isoladas** | Identificadores únicos por sessão de paciente. | Impede o vazamento de dados entre diferentes pacientes (Compliance LGPD).2 |
| **Redutores de Estado** | operator.add para histórico de mensagens. | Mantém o rastro completo de como o laudo evoluiu durante as rodadas de reflexão.8 |

## **Engenharia de Prompts Modulares e Camadas de Personalização**

Para satisfazer o requisito de que perfis de laudo (médico, escola, paciente) sejam comuns a vários questionários, a estratégia de "Prompts Componíveis" é a mais indicada.16 Esta abordagem trata o prompt final como um objeto dinâmico montado em tempo de execução, fundindo diretrizes globais com lógica de domínio específica.19

### **A Estrutura de Três Camadas do System Message**

A decomposição da lógica em três camadas independentes permite que o sistema escale sem redundância:

1. **Camada de Interpretação (Domínio):** Contém as regras clínicas específicas do questionário. Se o CHYPS-Br indica que um escore acima de X em certas questões sugere hipersensibilidade à luz, esta lógica reside exclusivamente aqui.2  
2. **Camada de Persona (Perfil):** Define o vocabulário e o tom. O laudo para a escola deve focar em adaptações pedagógicas, enquanto o laudo para o neurologista deve usar terminologia técnica precisa.12  
3. **Camada de Dados Contextuais:** O JSON bruto com as respostas e metadados do paciente, preferencialmente anonimizado antes do envio para modelos proprietários.2

Esta modularidade garante que, se a escola mudar suas diretrizes de acolhimento pedagógico, o desenvolvedor atualiza apenas o prompt de "Persona Escola", e todos os questionários do sistema (rápido, completo, CHYPS, etc.) passarão a gerar laudos no novo formato.19

### **Gestão Dinâmica via Prompt CMS**

O uso de sistemas de gerenciamento de prompts (Prompt CMS) como PromptLayer ou LangChain Prompt Hub permite que especialistas clínicos, que não necessariamente dominam o código-fonte, ajustem as instruções de interpretação diagnóstica em tempo real.22 A promoção de prompts através de ambientes de desenvolvimento, homologação e produção garante que mudanças na lógica diagnóstica sejam testadas rigorosamente antes de impactarem o paciente.24

| Prática de Gestão | Descrição | Impacto Operacional |
| :---- | :---- | :---- |
| **Versionamento Imutável** | Cada alteração gera uma nova versão com ID único. | Garante reprodutibilidade e facilita auditorias clínicas.24 |
| **Release Labels** | Uso de tags como prod, beta ou test. | Permite atualizações de prompt sem necessidade de novos deploys de código.22 |
| **A/B Testing** | Teste de variantes de persona simultaneamente. | Otimiza a clareza e a satisfação do paciente com base em métricas reais.26 |

## **Agent Skills: A Evolução da Inteligência Modular**

O conceito de "Agent Skills", introduzido recentemente por provedores como Anthropic e adotado por frameworks como Spring AI e LangChain Deep Agents, representa um salto arquitetural em relação às ferramentas (tools) tradicionais.28 Enquanto uma ferramenta é uma função executável, uma "Skill" é uma expertise empacotada que molda como o agente pensa e aborda um problema específico.31

### **Skills Clínicas e Divulgação Progressiva (Progressive Disclosure)**

Para o sistema proposto, a implementação de Skills permite que o agente carregue conhecimentos apenas quando necessário, economizando tokens e reduzindo a dispersão da atenção do modelo.32

* **Nível 1 (Metadados):** O agente sabe apenas os nomes e descrições das skills disponíveis (ex: "Skill de Interpretação CHYPS", "Skill de Encaminhamento Escolar").34  
* **Nível 2 (Instruções):** Somente quando o sistema identifica a necessidade de um laudo escolar, o arquivo SKILL.md correspondente é carregado no contexto do modelo.33  
* **Nível 3 (Scripts e Recursos):** A skill pode conter scripts Python para cálculos estatísticos complexos ou modelos de laudos em Markdown, carregados sob demanda.34

Esta arquitetura resolve o problema da "contaminação de contexto", onde instruções para um laudo médico poderiam influenciar indevidamente um laudo simplificado para o paciente.21 Além disso, skills são portáveis e podem ser compartilhadas entre diferentes agentes do sistema LAPAN, como o assistente de narrativa clínica e o gerador de laudos automatizado.2

### **Skills vs. Prompts: Quando Migrar?**

A evidência sugere que se uma instrução de interpretação de questionário é usada repetidamente em diferentes conversas e requer uma estrutura rígida, ela deve "graduar" de um prompt simples para uma Skill.29 As Skills permitem que a inteligência seja "incorporada" ao próprio comportamento do agente, tratando o conhecimento clínico como um manual de treinamento dinâmico, em vez de uma instrução efêmera.29

## **Adaptação de Parâmetros de Baixo Rank (LoRA) para Consistência de Estilo**

Embora a engenharia de prompts e as skills ofereçam controle sobre o conteúdo, a manutenção da consistência de tom e persona em larga escala pode ser desafiadora.37 A técnica de Low-Rank Adaptation (LoRA) surge como uma solução de Ajuste Fino Eficiente (PEFT) para garantir que a IA adote a voz exata necessária para cada perfil de laudo.39

### **Mecanismo Matemático e Eficiência do LoRA**

O LoRA congela os pesos originais do modelo base ($W\_0$) e injeta matrizes de baixo rank ($A$ e $B$) que aprendem os resíduos de estilo e formato.40 A atualização de pesos $\\Delta W$ é dada por:

$$W \= W\_0 \+ B \\cdot A$$  
onde o rank $r$ é significativamente menor que a dimensão do modelo original, permitindo que a adaptação ocupe apenas alguns megabytes.40 Para o sistema Hugo, isso significa que um único modelo base (ex: Llama 3.1 70B) pode servir simultaneamente laudos com estilos radicalmente diferentes através da troca rápida de adaptadores.40

| Tipo de Adaptador LoRA | Objetivo no LAPAN | Ganho de Desempenho |
| :---- | :---- | :---- |
| **Adaptador Médico** | Terminologia clínica técnica e concisão. | Redução de jargões imprecisos e maior alinhamento técnico.39 |
| **Adaptador Paciente** | Empatia, linguagem simples e acessibilidade. | Consistência tonal impossível de atingir apenas com prompts.44 |
| **Adaptador Estrutural** | Conformidade estrita com esquemas JSON ou Markdown. | 75% de redução na rejeição de formatos de saída.46 |

### **Multi-LoRA Serving e Latência na Groq**

O uso da infraestrutura Groq (LPUs) é particularmente vantajoso para o multi-LoRA serving.47 A Groq suporta a hospedagem de múltiplos adaptadores LoRA na mesma latência do modelo base, eliminando a penalidade de processamento comumente associada à troca de contextos em GPUs tradicionais.48 Isso permite que, em uma única sessão, o sistema gere as quatro versões do laudo (médico, escola, paciente, encaminhamento) de forma quase instantânea, mantendo a experiência do usuário fluida e sem interrupções.47  
É importante notar o fenômeno do "Alignment Tax": personas fortes via prompt podem prejudicar a precisão de recuperação de fatos médicos.51 O uso de adaptadores LoRA "gatilhados" (gated adapters) permite que o sistema desative o estilo de persona durante a fase de interpretação diagnóstica bruta e o reative apenas na fase de redação final, preservando a integridade dos dados clínicos.52

## **Redução de Alucinações Médicas através de Ciclos de Reflexão**

A geração de laudos médicos exige um rigor factual onde a tolerância para erros é zero.53 A arquitetura de reflexão (Reflexion) proposta pelo LangGraph transforma a geração de laudos em um processo iterativo de autocrítica e correção.15

### **Implementação do Nó de Crítica Clínica**

Dentro do grafo de estados, o laudo gerado inicialmente não é entregue ao usuário, mas sim passado para um nó de "Crítica".14 Este nó atua como um "Juiz IA" ou "Agente Guardião" que avalia o rascunho contra uma rubrica de qualidade médica.15

| Critério de Reflexão | Pergunta de Verificação | Mecanismo de Correção |
| :---- | :---- | :---- |
| **Precisão Lógica** | Todas as conclusões são suportadas pelos escores do questionário? | Comparação com dados brutos do estado.58 |
| **Recall Clínico** | Alguma alteração relevante detectada no questionário foi omitida? | Verificação de cobertura de entidades médicas.59 |
| **Consistência de Persona** | O tom está adequado para o destinatário (ex: escola)? | Re-formatação baseada em regras de estilo.15 |

Pesquisas indicam que a reflexão "direcionada" — onde o crítico aponta especificamente o erro — é superior à simples "correção cega".61 Além disso, o uso de modelos de raciocínio avançados (ex: GPT-4o ou Claude 3.5 Opus) para a fase de crítica, enquanto modelos menores e mais rápidos (ex: Llama 3.1 8B) lidam com o rascunho inicial, otimiza o custo sem sacrificar a segurança.15

### **Verificação Grounded e MEGA-RAG**

Para garantir a "Verdade Intrínseca", a reflexão deve ser complementada por bases de dados externas ou pela re-leitura rigorosa do contexto fornecido.15 O framework MEGA-RAG demonstra que cruzar as alegações do modelo com uma base de conhecimento clínico curada pode reduzir as taxas de alucinação em mais de 40%.64 No contexto do LAPAN, isso significa que cada afirmação no laudo ("O paciente apresenta escore indicativo de fotofobia") deve ser explicitamente validada contra o JSON de entrada no nó de reflexão antes da finalização.59

## **Infraestrutura e Performance: A Vantagem das LPUs**

A escolha entre GPUs tradicionais e LPUs (Language Processing Units) como a da Groq impacta diretamente a viabilidade de sistemas multiagentes complexos.48

### **Desempenho Determinístico e Latência**

Sistemas de apoio ao diagnóstico em tempo real exigem latência previsível.66 A arquitetura da Groq oferece execução determinística, o que significa que o tempo de geração do primeiro token (TTFT) permanece constante mesmo sob alta carga de tokens de entrada.47

* **Vantagem de Velocidade:** A Groq é capaz de entregar velocidades de geração (tokens/segundo) até 5 vezes superiores a alternativas baseadas em GPU.47  
* **Eficiência de Tokens:** Ao utilizar adaptadores LoRA que compartilham o modelo base, a Groq permite que múltiplos usuários sejam servidos com 90% menos consumo de memória de vídeo em comparação com o carregamento de modelos inteiros ajustados.68

### **Integração com vLLM e Batching Contínuo**

Para implementações híbridas ou locais, o vLLM oferece otimizações como PagedAttention, que permitem o "Batching Heterogêneo de LoRAs".43 Isso significa que o servidor pode processar simultaneamente uma solicitação de laudo para médico (Adaptador A) e uma para escola (Adaptador B) no mesmo lote de inferência, maximizando o throughput do sistema sem comprometer a especificidade estilística de cada laudo.70

## **Governança de Dados e Conformidade (LGPD e Auditoria)**

Como o sistema lida com dados de saúde e menores de idade no Brasil, a conformidade com a LGPD é um pilar central da arquitetura.2

### **Privacidade no Processamento de IA**

O sistema deve implementar uma camada de "Sanitização de Dados" (PII Masking) antes que os dados saiam do ambiente controlado (survey-backend) para a API de IA (clinical-writer-api).2

| Medida de Segurança | Implementação Técnica | Requisito Legal |
| :---- | :---- | :---- |
| **Pseudonimização** | Substituição de nomes por IDs únicos no grafo de estado. | Proteção de dados sensíveis (Art. 13 LGPD).2 |
| **Audit Logs de Prompt** | Registro de qual versão de prompt gerou qual laudo. | Transparência e explicabilidade (Art. 20 LGPD).2 |
| **Consentimento Granular** | Tags de permissão para compartilhamento de laudos IA. | Finalidade e necessidade (Art. 6 LGPD).2 |

A integração de "Guardian Agents" no LangGraph atua não apenas como revisores clínicos, mas também como monitores de conformidade, bloqueando a geração de laudos que contenham termos estigmatizantes ou dados que não foram explicitamente autorizados pelo responsável legal do paciente.15

## **Futuro da Documentação Assistida e Diagnóstico Multimodal**

A trajetória tecnológica iniciada com o projeto LAPAN aponta para sistemas que transcendem o texto.66 A integração de dados multimodais — como padrões de rastreamento ocular (eye-tracking) capturados durante a resposta ao questionário ou sinais biométricos — permitirá que a IA realize inferências de maior ordem sobre o estado do neurodesenvolvimento.73

### **Quantum AI e Modelos de Alta Dimensionalidade**

Frameworks emergentes como o "Modelo Aurora" propõem que a inteligência artificial evolua para uma representação fractal e recursiva do conhecimento.76 Ao mapear a lógica clínica em espaços vetoriais de alta dimensionalidade, sistemas futuros poderão realizar sínteses de conhecimento que são rastreáveis e reversíveis, garantindo que cada vírgula de um laudo médico tenha uma fundamentação geométrica e lógica inquestionável.76

### **Calibração de Confiança Dinâmica**

O grande obstáculo para a adoção em massa da IA clínica é o excesso de confiança em erros ("Plausibility Paradox").66 Sistemas de próxima geração estão incorporando "Dynamic Scoring Frameworks" que ajustam os limiares de intervenção médica com base na incerteza calculada do modelo.67 Se o agente gerar um laudo de encaminhamento com baixa similaridade semântica em relação aos dados históricos do paciente, o sistema automaticamente acionará um alerta crítico para revisão humana imediata, garantindo que a tecnologia atue como um amplificador da perícia médica, e não como um substituto falível.67

## **Conclusões e Recomendações Estratégicas**

A análise exaustiva das tecnologias e frameworks atuais permite delinear um plano de ação robusto para a implementação do sistema de apoio ao diagnóstico modular. A convergência de orquestração via LangGraph, gestão de expertises através de Agent Skills e refinamento estilístico com LoRA constitui o estado-da-arte para documentação clínica automatizada.4  
Para Hugo e a equipe do projeto LAPAN, recomendam-se as seguintes diretrizes técnicas:

* **Migração para Arquitetura Multiagente Stateful:** Implementar o LangGraph para gerenciar a separação entre interpretação diagnóstica e geração de personas, garantindo persistência e auditabilidade.4  
* **Padronização de Skills Clínicas:** Encapsular a lógica de cada questionário (ex: CHYPS-Br) em Skills modulares baseadas em arquivos, facilitando a manutenção descentralizada por diferentes equipes clínicas.29  
* **Adoção de LoRA para Perfis Recorrentes:** Treinar adaptadores LoRA leves para as personas "Médico", "Escola" e "Paciente" para garantir consistência tonal inabalável, servindo-os via Groq para performance de baixa latência.40  
* **Institucionalização de Ciclos de Reflexão:** Implementar nós de reflexão e crítica clínica no grafo para mitigar alucinações e assegurar que todos os laudos sejam estritamente grounded nos dados do questionário.14  
* **Governança de Prompts Fora do Código:** Utilizar um Prompt CMS para gerenciar o ciclo de vida e o versionamento das instruções, permitindo iterações rápidas sem deploys complexos.18

Ao adotar este ecossistema modular e orientado a estados, o sistema não apenas resolverá a necessidade imediata de múltiplos laudos por questionário, mas se posicionará como uma plataforma escalável capaz de absorver novas escalas e modalidades diagnósticas com esforço de engenharia marginal, sempre priorizando a segurança do paciente e a precisão do cuidado clínico.16

#### **Referências citadas**

1. An Investigation of Evaluation Metrics for Automated Medical Note Generation \- Microsoft, acessado em março 24, 2026, [https://www.microsoft.com/en-us/research/wp-content/uploads/2023/07/Final-ACL2023\_EvalMetrics.pdf](https://www.microsoft.com/en-us/research/wp-content/uploads/2023/07/Final-ACL2023_EvalMetrics.pdf)  
2. GEMINI.md  
3. LangGraph-based production-style RAG (Parent-Child retrieval, idempotent ingestion) — feedback on recursive loops? : r/LangChain \- Reddit, acessado em março 24, 2026, [https://www.reddit.com/r/LangChain/comments/1rbd4x5/langgraphbased\_productionstyle\_rag\_parentchild/](https://www.reddit.com/r/LangChain/comments/1rbd4x5/langgraphbased_productionstyle_rag_parentchild/)  
4. LangGraph: Multi-Agent Workflows \- LangChain Blog, acessado em março 24, 2026, [https://blog.langchain.com/langgraph-multi-agent-workflows/](https://blog.langchain.com/langgraph-multi-agent-workflows/)  
5. LangGraph: Agent Orchestration Framework for Reliable AI Agents \- LangChain, acessado em março 24, 2026, [https://www.langchain.com/langgraph](https://www.langchain.com/langgraph)  
6. Multi-agent \- Docs by LangChain, acessado em março 24, 2026, [https://docs.langchain.com/oss/python/langchain/multi-agent](https://docs.langchain.com/oss/python/langchain/multi-agent)  
7. LangChain & LangGraph: LLM Workflow Orchestration \- Emergent Mind, acessado em março 24, 2026, [https://www.emergentmind.com/topics/langchain-langgraph](https://www.emergentmind.com/topics/langchain-langgraph)  
8. LangGraph State Management — Part 1: How LangGraph Manages ..., acessado em março 24, 2026, [https://medium.com/@bharatraj1918/langgraph-state-management-part-1-how-langgraph-manages-state-for-multi-agent-workflows-da64d352c43b](https://medium.com/@bharatraj1918/langgraph-state-management-part-1-how-langgraph-manages-state-for-multi-agent-workflows-da64d352c43b)  
9. LangGraph: Building Intelligent Multi-Agent Workflows with State Management \- Medium, acessado em março 24, 2026, [https://medium.com/@saimoguloju2/langgraph-building-intelligent-multi-agent-workflows-with-state-management-0427264b6318](https://medium.com/@saimoguloju2/langgraph-building-intelligent-multi-agent-workflows-with-state-management-0427264b6318)  
10. How to Build Effective Agentic Systems with LangGraph | Towards Data Science, acessado em março 24, 2026, [https://towardsdatascience.com/how-to-build-effective-agentic-systems-with-langgraph/](https://towardsdatascience.com/how-to-build-effective-agentic-systems-with-langgraph/)  
11. Three LangGraph Agent Patterns That Replaced Hundreds of Lines of Glue Code \- Dev.to, acessado em março 24, 2026, [https://dev.to/irubtsov/three-langgraph-agent-patterns-that-replaced-hundreds-of-lines-of-glue-code-3a21](https://dev.to/irubtsov/three-langgraph-agent-patterns-that-replaced-hundreds-of-lines-of-glue-code-3a21)  
12. Decoding large language models for radiology: strategies for fine-tuning and prompt engineering \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12429228/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12429228/)  
13. Building Smart AI Agents: A Practical Guide to LangGraph Design Patterns \- Towards AI, acessado em março 24, 2026, [https://pub.towardsai.net/building-smart-ai-agents-a-practical-guide-to-langgraph-design-patterns-65d160709b94](https://pub.towardsai.net/building-smart-ai-agents-a-practical-guide-to-langgraph-design-patterns-65d160709b94)  
14. Built with LangGraph\! \#29: Reflection & Reflexion | by Okan Yenigün \- Medium, acessado em março 24, 2026, [https://medium.com/@okanyenigun/built-with-langgraph-29-reflection-reflexion-10cc1cf96f35](https://medium.com/@okanyenigun/built-with-langgraph-29-reflection-reflexion-10cc1cf96f35)  
15. The Reflection Pattern: Why Self-Reviewing AI Improves Quality, acessado em março 24, 2026, [https://qat.com/reflection-pattern-ai/](https://qat.com/reflection-pattern-ai/)  
16. 5 Skills Every AI Agent Needs (And Why Your Mega-Prompt Is Holding You Back) | by Micheal Lanham | Feb, 2026, acessado em março 24, 2026, [https://medium.com/@Micheal-Lanham/5-skills-every-ai-agent-needs-and-why-your-mega-prompt-is-holding-you-back-4b4ab2471c0e](https://medium.com/@Micheal-Lanham/5-skills-every-ai-agent-needs-and-why-your-mega-prompt-is-holding-you-back-4b4ab2471c0e)  
17. Mastering LangGraph State Management in 2025 \- Sparkco, acessado em março 24, 2026, [https://sparkco.ai/blog/mastering-langgraph-state-management-in-2025](https://sparkco.ai/blog/mastering-langgraph-state-management-in-2025)  
18. Best practices: Prompt management and collaboration | by Jared Zoneraich | PromptLayer, acessado em março 24, 2026, [https://medium.com/promptlayer/scalable-prompt-management-and-collaboration-fff28af39b9b](https://medium.com/promptlayer/scalable-prompt-management-and-collaboration-fff28af39b9b)  
19. Context engineering in agents \- Docs by LangChain, acessado em março 24, 2026, [https://docs.langchain.com/oss/python/langchain/context-engineering](https://docs.langchain.com/oss/python/langchain/context-engineering)  
20. Prompt Engineering in Clinical Practice: Tutorial for Clinicians \- Journal of Medical Internet Research, acessado em março 24, 2026, [https://www.jmir.org/2025/1/e72644](https://www.jmir.org/2025/1/e72644)  
21. What Are Agent Skills? Modular AI Agent Frameworks Explained \- DataCamp, acessado em março 24, 2026, [https://www.datacamp.com/blog/agent-skills](https://www.datacamp.com/blog/agent-skills)  
22. Prompt Management \- PromptLayer, acessado em março 24, 2026, [https://docs.promptlayer.com/onboarding-guides/prompt-management](https://docs.promptlayer.com/onboarding-guides/prompt-management)  
23. Langfuse vs Langchain vs Promptlayer: Feature Comparison & Guide, acessado em março 24, 2026, [https://blog.promptlayer.com/langfuse-vs-langchain-vs-promptlayer/](https://blog.promptlayer.com/langfuse-vs-langchain-vs-promptlayer/)  
24. Prompt Versioning & Management Guide for Building AI Features ..., acessado em março 24, 2026, [https://launchdarkly.com/blog/prompt-versioning-and-management/](https://launchdarkly.com/blog/prompt-versioning-and-management/)  
25. What is prompt management? Versioning, collaboration, and deployment for prompts \- Articles \- Braintrust, acessado em março 24, 2026, [https://www.braintrust.dev/articles/what-is-prompt-management](https://www.braintrust.dev/articles/what-is-prompt-management)  
26. What is the A/B testing framework for intelligent databases? \- Tencent Cloud, acessado em março 24, 2026, [https://www.tencentcloud.com/techpedia/142278](https://www.tencentcloud.com/techpedia/142278)  
27. A/B Testing Prompts: A Complete Guide to Optimizing LLM Performance \- DEV Community, acessado em março 24, 2026, [https://dev.to/kuldeep\_paul/ab-testing-prompts-a-complete-guide-to-optimizing-llm-performance-1442](https://dev.to/kuldeep_paul/ab-testing-prompts-a-complete-guide-to-optimizing-llm-performance-1442)  
28. Anthropic Says Don’t Build Agents, Build Skills Instead\!, acessado em março 24, 2026, [https://cobusgreyling.medium.com/anthropic-says-dont-build-agents-build-skills-instead-47e1a88435ab](https://cobusgreyling.medium.com/anthropic-says-dont-build-agents-build-skills-instead-47e1a88435ab)  
29. Agent Skills Vs MCP Vs Prompts Vs Projects Vs Subagents :A Comparative Analysis | by Tahir | Jan, 2026, acessado em março 24, 2026, [https://medium.com/@tahirbalarabe2/agent-skills-vs-mcp-vs-prompts-vs-projects-vs-subagents-a-comparative-analysis-7a36cd85cb74](https://medium.com/@tahirbalarabe2/agent-skills-vs-mcp-vs-prompts-vs-projects-vs-subagents-a-comparative-analysis-7a36cd85cb74)  
30. Spring AI Agentic Patterns (Part 1): Agent Skills \- Modular, Reusable Capabilities, acessado em março 24, 2026, [https://spring.io/blog/2026/01/13/spring-ai-generic-agent-skills/](https://spring.io/blog/2026/01/13/spring-ai-generic-agent-skills/)  
31. Skills vs Tools for AI Agents: Production Guide \- Arcade.dev, acessado em março 24, 2026, [https://www.arcade.dev/blog/what-are-agent-skills-and-tools/](https://www.arcade.dev/blog/what-are-agent-skills-and-tools/)  
32. Agent Skills vs MCP: What’s the difference?, acessado em março 24, 2026, [https://www.youtube.com/watch?v=6wdvSH61xGw](https://www.youtube.com/watch?v=6wdvSH61xGw)  
33. Using skills with Deep Agents \- LangChain Blog, acessado em março 24, 2026, [https://blog.langchain.com/using-skills-with-deep-agents/](https://blog.langchain.com/using-skills-with-deep-agents/)  
34. Agent Skills \- Claude API Docs, acessado em março 24, 2026, [https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)  
35. Agent Skills for LangChain: Making AI Assistants Context-Aware | Simon Budziak | Medium, acessado em março 24, 2026, [https://medium.com/@simon.budziak/agent-skills-for-langchain-making-ai-assistants-context-aware-04791206622d](https://medium.com/@simon.budziak/agent-skills-for-langchain-making-ai-assistants-context-aware-04791206622d)  
36. Agent Skill Guide: Tools, Memory, and Modular AI Design \- Thesys, acessado em março 24, 2026, [https://www.thesys.dev/blogs/agent-skill](https://www.thesys.dev/blogs/agent-skill)  
37. Self-Supervised Persona (Auto Fine-Tuning LLMs) | by Aadharsh Kannan | Medium, acessado em março 24, 2026, [https://medium.com/@aadharshkannan/self-supervised-persona-auto-fine-tuning-llms-af30fa3ff192](https://medium.com/@aadharshkannan/self-supervised-persona-auto-fine-tuning-llms-af30fa3ff192)  
38. When ”A Helpful Assistant” Is Not Really Helpful: Personas in System Prompts Do Not Improve Performances of Large Language Models | Request PDF \- ResearchGate, acessado em março 24, 2026, [https://www.researchgate.net/publication/386182602\_When\_A\_Helpful\_Assistant\_Is\_Not\_Really\_Helpful\_Personas\_in\_System\_Prompts\_Do\_Not\_Improve\_Performances\_of\_Large\_Language\_Models](https://www.researchgate.net/publication/386182602_When_A_Helpful_Assistant_Is_Not_Really_Helpful_Personas_in_System_Prompts_Do_Not_Improve_Performances_of_Large_Language_Models)  
39. Prompted vs Fine-Tuned (LoRA/PEFT): A Practical Sequel to Patient Journey Mapping with Small LLMs | by Sabarinath Venkatajalam | Medium, acessado em março 24, 2026, [https://medium.com/@sabarinathvenkat/prompted-vs-fine-tuned-lora-peft-a-practical-sequel-to-patient-journey-mapping-with-small-llms-618b7bec69ee](https://medium.com/@sabarinathvenkat/prompted-vs-fine-tuned-lora-peft-a-practical-sequel-to-patient-journey-mapping-with-small-llms-618b7bec69ee)  
40. The “Death” of Fine-Tuning: LoRA, QLoRA, Adapters, and Soft Prompts in Production (2025), acessado em março 24, 2026, [https://medium.com/@swatipatel108/the-death-of-fine-tuning-lora-qlora-adapters-and-soft-prompts-in-production-2025-d9309e0b4d69](https://medium.com/@swatipatel108/the-death-of-fine-tuning-lora-qlora-adapters-and-soft-prompts-in-production-2025-d9309e0b4d69)  
41. A journey from LoRA to Text-to-LoRA — Fine-tuning LLM using prompt | by Shilpa Thota, acessado em março 24, 2026, [https://shilpathota.medium.com/a-journey-from-lora-to-text-to-lora-fine-tuning-llm-using-prompt-df59a4bc6c43](https://shilpathota.medium.com/a-journey-from-lora-to-text-to-lora-fine-tuning-llm-using-prompt-df59a4bc6c43)  
42. Fine-Tuning vs Prompt Engineering: Which One Should You Learn First? | by Tejas Doypare, acessado em março 24, 2026, [https://medium.com/@tejasdoypare/fine-tuning-vs-prompt-engineering-which-one-should-you-learn-first-cdca04e21d6c](https://medium.com/@tejasdoypare/fine-tuning-vs-prompt-engineering-which-one-should-you-learn-first-cdca04e21d6c)  
43. Efficiently Deploying LoRA Adapters: Optimizing LLM Fine-Tuning for Multi-Task AI, acessado em março 24, 2026, [https://www.inferless.com/learn/how-to-serve-multi-lora-adapters](https://www.inferless.com/learn/how-to-serve-multi-lora-adapters)  
44. AI in Healthcare, Part 6: Prompting Techniques and Fine‑Tuning ..., acessado em março 24, 2026, [https://medium.com/@swatimaste8/ai-in-healthcare-part-6-prompting-techniques-and-fine-tuning-llms-for-healthcare-qa-60f5bd3bdadf](https://medium.com/@swatimaste8/ai-in-healthcare-part-6-prompting-techniques-and-fine-tuning-llms-for-healthcare-qa-60f5bd3bdadf)  
45. StyleAdaptedLM: Enhancing Instruction Following Models with Efficient Stylistic Transfer, acessado em março 24, 2026, [https://arxiv.org/html/2507.18294v1](https://arxiv.org/html/2507.18294v1)  
46. Phi Silica task specialization using LoRA in Microsoft Learning Zone: A technical deep dive, acessado em março 24, 2026, [https://blogs.windows.com/windowsdeveloper/2025/07/31/phi-silica-task-specialization-using-lora-in-microsoft-learning-zone-a-technical-deep-dive/](https://blogs.windows.com/windowsdeveloper/2025/07/31/phi-silica-task-specialization-using-lora-in-microsoft-learning-zone-a-technical-deep-dive/)  
47. Groq Recognized in 2025 Gartner® Cool Vendor in AI Infrastructure report, acessado em março 24, 2026, [https://groq.com/blog/groq-recognized-gartner-cool-vendor](https://groq.com/blog/groq-recognized-gartner-cool-vendor)  
48. LoRA Inference \- GroqDocs \- Groq Console, acessado em março 24, 2026, [https://console.groq.com/docs/lora](https://console.groq.com/docs/lora)  
49. LoRA Fine-Tune Support Now Live on GroqCloud | Groq is fast, low cost inference., acessado em março 24, 2026, [https://groq.com/blog/introducing-groqcloud-lora-fine-tune-support-unlock-efficient-model-adaptation-for-enterprises](https://groq.com/blog/introducing-groqcloud-lora-fine-tune-support-unlock-efficient-model-adaptation-for-enterprises)  
50. Understanding and Optimizing Latency \- GroqDocs \- Groq Console, acessado em março 24, 2026, [https://console.groq.com/docs/production-readiness/optimizing-latency](https://console.groq.com/docs/production-readiness/optimizing-latency)  
51. Expert Personas Improve LLM Alignment but Damage Accuracy: Bootstrapping Intent-Based Persona Routing with PRISM \- arXiv, acessado em março 24, 2026, [https://arxiv.org/html/2603.18507v1](https://arxiv.org/html/2603.18507v1)  
52. Is "You're an expert" the Poison of AI Hallucinations? New Paper Exposes Biggest Scam of Prompt Words, acessado em março 24, 2026, [https://eu.36kr.com/en/p/3736415004590339](https://eu.36kr.com/en/p/3736415004590339)  
53. Medical Hallucination in Foundation Models and Their Impact on Healthcare \- medRxiv, acessado em março 24, 2026, [https://www.medrxiv.org/content/10.1101/2025.02.28.25323115v2.full.pdf](https://www.medrxiv.org/content/10.1101/2025.02.28.25323115v2.full.pdf)  
54. GitHub \- mitmedialab/medical\_hallucination: Medical Hallucination in Foundation Models and Their Impact on Healthcare (2025), acessado em março 24, 2026, [https://github.com/mitmedialab/medical\_hallucination](https://github.com/mitmedialab/medical_hallucination)  
55. Reflection Pattern \- Self-Reflection and Self-Correction in Agentic AI \- DataFlair, acessado em março 24, 2026, [https://data-flair.training/blogs/reflection-pattern-self-reflection-and-self-correction-in-agentic-ai/](https://data-flair.training/blogs/reflection-pattern-self-reflection-and-self-correction-in-agentic-ai/)  
56. langchain-ai/langgraph-reflection \- GitHub, acessado em março 24, 2026, [https://github.com/langchain-ai/langgraph-reflection](https://github.com/langchain-ai/langgraph-reflection)  
57. LangChain/LangGraph: Build Reflection Enabled Agentic | by TeeTracker \- Medium, acessado em março 24, 2026, [https://teetracker.medium.com/build-reflection-enabled-agent-9186a35c6581](https://teetracker.medium.com/build-reflection-enabled-agent-9186a35c6581)  
58. Faithful AI in Medicine: A Systematic Review with Large Language Models and Beyond \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC10723541/](https://pmc.ncbi.nlm.nih.gov/articles/PMC10723541/)  
59. Evaluating automated radiology reports \- Mecha Health, acessado em março 24, 2026, [https://www.mecha-health.ai/blog/Evaluating-automated-radiology-reports](https://www.mecha-health.ai/blog/Evaluating-automated-radiology-reports)  
60. Medical Hallucination in Foundation Models and Their Impact on Healthcare \- medRxiv.org, acessado em março 24, 2026, [https://www.medrxiv.org/content/10.1101/2025.02.28.25323115v1.full](https://www.medrxiv.org/content/10.1101/2025.02.28.25323115v1.full)  
61. MedReflect: Teaching Medical LLMs to Self-Improve via Reflective Correction \- arXiv, acessado em março 24, 2026, [https://arxiv.org/html/2510.03687v2](https://arxiv.org/html/2510.03687v2)  
62. Enhancing Code Quality with LangGraph Reflection \- Analytics Vidhya, acessado em março 24, 2026, [https://www.analyticsvidhya.com/blog/2025/03/enhancing-code-quality-with-langgraph-reflection/](https://www.analyticsvidhya.com/blog/2025/03/enhancing-code-quality-with-langgraph-reflection/)  
63. Self-Reflective RAG with LangGraph \- LangChain Blog, acessado em março 24, 2026, [https://blog.langchain.com/agentic-rag-with-langgraph/](https://blog.langchain.com/agentic-rag-with-langgraph/)  
64. MEGA-RAG: a retrieval-augmented generation framework with multi-evidence guided answer refinement for mitigating hallucinations of LLMs in public health \- PMC \- NIH, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12540348/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12540348/)  
65. Trustworthy AI for Medicine: Continuous Hallucination Detection and Elimination with CHECK \- arXiv, acessado em março 24, 2026, [https://arxiv.org/html/2506.11129v1](https://arxiv.org/html/2506.11129v1)  
66. Automated Radiology Report Generation Using Multimodal Foundation Models: A Systematic Review Of Clinical Accuracy And Safety, acessado em março 24, 2026, [https://diabeticstudies.org/index.php/RDS/article/view/1682/1496](https://diabeticstudies.org/index.php/RDS/article/view/1682/1496)  
67. Enhancing Clinician Trust in AI Diagnostics: A Dynamic Framework for Confidence Calibration and Transparency \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12428550/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12428550/)  
68. Prompt Engineering vs Fine Tuning: When to Use Each | Codecademy, acessado em março 24, 2026, [https://www.codecademy.com/article/prompt-engineering-vs-fine-tuning](https://www.codecademy.com/article/prompt-engineering-vs-fine-tuning)  
69. Efficiently serve dozens of fine-tuned models with vLLM on Amazon SageMaker AI and Amazon Bedrock | Artificial Intelligence \- AWS, acessado em março 24, 2026, [https://aws.amazon.com/blogs/machine-learning/efficiently-serve-dozens-of-fine-tuned-models-with-vllm-on-amazon-sagemaker-ai-and-amazon-bedrock/](https://aws.amazon.com/blogs/machine-learning/efficiently-serve-dozens-of-fine-tuned-models-with-vllm-on-amazon-sagemaker-ai-and-amazon-bedrock/)  
70. Clarification: Does vLLM support concurrent decoding with multiple LoRA adapters in online inference?, acessado em março 24, 2026, [https://discuss.vllm.ai/t/clarification-does-vllm-support-concurrent-decoding-with-multiple-lora-adapters-in-online-inference/1482](https://discuss.vllm.ai/t/clarification-does-vllm-support-concurrent-decoding-with-multiple-lora-adapters-in-online-inference/1482)  
71. Evaluating clinical AI summaries with large language models as judges \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12589481/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12589481/)  
72. Healthcare AI Agents: Core Components and Architectures \- CIOCoverage, acessado em março 24, 2026, [https://www.ciocoverage.com/healthcare-ai-agents-core-components-and-architectures/](https://www.ciocoverage.com/healthcare-ai-agents-core-components-and-architectures/)  
73. Reimagining Mental Health with Artificial Intelligence: Early Detection, Personalized Care, and a Preventive Ecosystem \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12604579/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12604579/)  
74. AURA: A Multi-Modal Medical Agent for Understanding, Reasoning & Annotation \- arXiv.org, acessado em março 24, 2026, [https://arxiv.org/html/2507.16940v1](https://arxiv.org/html/2507.16940v1)  
75. Artificial intelligence‐based algorithms for the diagnosis of retinopathy of prematurity \- PMC, acessado em março 24, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC12502027/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12502027/)  
76. The Aurora Model: Architecture of Intelligence Based on Logical Coherence \- Medium, acessado em março 24, 2026, [https://medium.com/@pab.man.alvarez/the-aurora-model-architecture-of-intelligence-based-on-logical-coherence-09d665a3be3c](https://medium.com/@pab.man.alvarez/the-aurora-model-architecture-of-intelligence-based-on-logical-coherence-09d665a3be3c)  
77. The 7-Layer Architecture for an Ethical Collective Intelligence | by Aurora Program \- Medium, acessado em março 24, 2026, [https://medium.com/@pab.man.alvarez/aurora-the-7-layer-architecture-for-an-ethical-collective-intelligence-132940e66bfb](https://medium.com/@pab.man.alvarez/aurora-the-7-layer-architecture-for-an-ethical-collective-intelligence-132940e66bfb)  
78. Enhancing Clinician Trust in AI Diagnostics: A Dynamic Framework for Confidence Calibration and Transparency \- MDPI, acessado em março 24, 2026, [https://www.mdpi.com/2075-4418/15/17/2204](https://www.mdpi.com/2075-4418/15/17/2204)  
79. SHAPE-AI: Development and Expert Validation of a Survey for Human–AI Performance Evaluation in Healthcare \- medRxiv, acessado em março 24, 2026, [https://www.medrxiv.org/content/10.64898/2026.01.18.26344350v1.full.pdf](https://www.medrxiv.org/content/10.64898/2026.01.18.26344350v1.full.pdf)  
80. Agentic AI in healthcare: a new era of intelligent automation, acessado em março 24, 2026, [https://www.kore.ai/blog/agentic-ai-in-healthcare](https://www.kore.ai/blog/agentic-ai-in-healthcare)  
81. Advocate Health Deploys AI Solution to Redefine Diagnostic Excellence through Agreement with Aidoc, acessado em março 24, 2026, [https://www.advocatehealth.org/news/advocate-health-deploys-ai-solution-to-redefine-diagnostic-excellence-through-agreement-with-aidoc](https://www.advocatehealth.org/news/advocate-health-deploys-ai-solution-to-redefine-diagnostic-excellence-through-agreement-with-aidoc)