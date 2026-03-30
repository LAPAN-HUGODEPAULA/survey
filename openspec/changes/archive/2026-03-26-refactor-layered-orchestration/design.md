# Design: Layered Graph Orchestration

## State Management

A adoção do grafo em camadas exige a evolução do contrato central, o `AgentState`. Atualmente ele foca no status de validação e tipo de input. Ele será estendido para gerenciar o contexto carregado e os resultados intermediários (fatos clínicos).

```python
class AgentState(TypedDict, total=False):
    # Core Request
    input_content: str
    prompt_key: str
    persona_key: str
    
    # Hydrated Context (from ContextLoader)
    interpretation_prompt: str
    persona_prompt: str
    
    # Intermediate State (from ClinicalAnalyzer)
    clinical_facts: dict
    
    # Generation (from PersonaWriter)
    draft_narrative: str
    
    # Audit & Reflection
    validation_status: str
    error_message: str
    reflection_count: int
```

## Node Architecture & Data Flow

A nova topologia desmembra a cognição do LLM em nós especializados, permitindo o uso de modelos assíncronos e de diferentes tamanhos no futuro (e.g., modelos menores para análise, maiores para crítica).

1. **ContextLoader Node**
   - **Responsibility:** Recupera do MongoDB as configurações específicas de domínio e estilo.
   - **Data Flow:** Lê `prompt_key` e `persona_key`. Grava `interpretation_prompt` e `persona_prompt` no estado.

2. **ClinicalAnalyzer Node**
   - **Responsibility:** Ingestão de `input_content` e aplicação do `interpretation_prompt`.
   - **Data Flow:** O modelo instruído gera e retorna exclusivamente uma estrutura JSON com os fatos clínicos deduzidos. Grava em `clinical_facts`.
   - **Design Choice:** Ao impedir a prosa neste passo, garantimos que o LLM foque apenas na extração analítica sem se preocupar com tom ou estrutura.

3. **PersonaWriter Node**
   - **Responsibility:** Ingestão do `clinical_facts` (não do `input_content` original diretamente) e do `persona_prompt`.
   - **Data Flow:** Produz o relatório final. Grava em `draft_narrative` (ou `medical_record`).

4. **ReflectorNode (Future/Critique Integration)**
   - **Responsibility:** O rascunho passa por uma verificação cruzada com o `input_content`. Retorna um veredito (`PASS` ou `FAIL`). Bordas condicionais (`conditional_edge`) retornam ao Writer em caso de falha.

## Backward Compatibility

Os endpoints FastAPI (como `process_consult` e `process_survey7`) continuarão enviando o mesmo payload. Se um request for para um tipo legado ou o banco de dados não contiver o mapeamento da persona, o `ContextLoader` pode retornar um erro elegante ou acionar o nó de fallback (`OtherInputHandlerAgent`), preservando a estabilidade da API em produção.