"""Shared starter prompt catalog seed data for Mongo migrations."""

from __future__ import annotations

from datetime import datetime, timezone


CATALOG_SEED_SOURCE = "starter_prompt_catalog_v1"

LEGACY_SURVEY_PROMPT_KEY = "survey7"
LEGACY_SURVEY_PROMPT_NAME = "Structured Survey Clinical Report"
LEGACY_SURVEY_PROMPT_TEXT = """
Você receberá um JSON com um questionário aplicado e deverá produzir um laudo clínico estruturado em português brasileiro.

Regras:
- Use apenas os dados presentes no JSON.
- Não invente diagnósticos ou fatos não informados.
- Considere dados demográficos e histórico clínico quando existirem.
- Interprete as respostas do questionário de forma objetiva e conservadora.
- Produza um texto técnico, adequado para prontuário.
""".strip()

LEGACY_NEUROCHECK_PROMPT_KEY = "neurocheck"
LEGACY_NEUROCHECK_PROMPT_NAME = "NeuroCheck Clinical Report"
LEGACY_NEUROCHECK_PROMPT_TEXT = """
Você receberá um JSON com o questionário NeuroCheck (Indicador de Saúde Mental e Sensorial) e deverá produzir um laudo clínico estruturado em português brasileiro.

O questionário avalia 4 eixos principais:
1. Fotosensibilidade (Luz Natural, Luz Artificial, Faróis, Cores)
2. Visuomotor (Enjôo, Leitura)
3. Filtros (Tato, Paladar, Olfato, Audição)
4. Biológico (Enxaqueca, Familiar)

O sistema de pontuação é: Confortável (0), Razoável (2), Desconfortável (5).

Regras para o laudo:
- Analise a pontuação em cada um dos 4 eixos.
- Identifique sinais de sobrecarga biológica (uma pontuação total superior a 24 indica sobrecarga).
- Descreva o impacto funcional sugerido pelas respostas em cada eixo.
- Mantenha um tom técnico, objetivo e clínico.
- Use apenas as informações fornecidas no JSON.
""".strip()

OLD_PERSONA_SKILL_SEEDS = {
    "patient_condition_overview": {
        "personaSkillKey": "patient_condition_overview",
        "name": "Patient Condition Overview",
        "outputProfile": "patient_condition_overview",
        "instructions": (
            "Write a concise patient-facing clinical summary in Brazilian Portuguese. "
            "Keep the tone calm, conservative, and free of school-specific language."
        ),
    },
    "clinical_diagnostic_report": {
        "personaSkillKey": "clinical_diagnostic_report",
        "name": "Clinical Diagnostic Report",
        "outputProfile": "clinical_diagnostic_report",
        "instructions": (
            "Write in formal clinical language appropriate for the medical record. "
            "Emphasize evidence, uncertainty, and objective interpretation."
        ),
    },
    "clinical_referral_letter": {
        "personaSkillKey": "clinical_referral_letter",
        "name": "Clinical Referral Letter",
        "outputProfile": "clinical_referral_letter",
        "instructions": (
            "Write as a formal referral letter in Brazilian Portuguese. "
            "Highlight the referral rationale, key findings, and next-step recommendations."
        ),
    },
    "parental_guidance": {
        "personaSkillKey": "parental_guidance",
        "name": "Parental Guidance",
        "outputProfile": "parental_guidance",
        "instructions": (
            "Write for caregivers in clear and supportive language. "
            "Preserve clinical accuracy while avoiding unnecessarily technical terms."
        ),
    },
    "school_report": {
        "personaSkillKey": "school_report",
        "name": "School Report Persona",
        "outputProfile": "school_report",
        "instructions": (
            "Write for a school team in formal collaborative language. "
            "Focus on functional impact, classroom support needs, and respectful tone."
        ),
    },
}

QUESTIONNAIRE_PROMPT_SEEDS = [
    {
        "promptKey": LEGACY_SURVEY_PROMPT_KEY,
        "name": LEGACY_SURVEY_PROMPT_NAME,
        "promptText": LEGACY_SURVEY_PROMPT_TEXT,
    },
    {
        "promptKey": LEGACY_NEUROCHECK_PROMPT_KEY,
        "name": LEGACY_NEUROCHECK_PROMPT_NAME,
        "promptText": LEGACY_NEUROCHECK_PROMPT_TEXT,
    },
    {
        "promptKey": "lapan_q7_clinical_logic",
        "name": "LAPAN Q7 Clinical Logic",
        "promptText": """
Instrumento: LAPAN Q7, questionário de hipersensibilidade visual e sobrecarga sensorial.

Use o JSON recebido para interpretar exclusivamente o raciocínio clínico do instrumento, sem adicionar tom voltado a paciente, escola ou encaminhamento.

Regras de entrada:
- Considere dados do paciente apenas quando estiverem presentes no JSON.
- Trate o instrumento como um rastreio e não como diagnóstico definitivo.
- Use somente fatos informados na aplicação.

Pontuação:
- Quase Nunca = 0
- Ocasionalmente = 1
- Frequentemente = 2
- Quase Sempre = 3

Tarefas obrigatórias:
1. Calcular o escore total do LAPAN Q7.
2. Descrever a distribuição das respostas entre os itens.
3. Produzir observações por subtipo visual:
   - Brilho/Fotofobia: itens 1 e 6.
   - Movimento ou estímulos estroboscópicos: itens 4 e 6.
   - Ambientes visuais intensos e sobrecarga contextual: itens 2 e 7.
4. Tratar os itens 3 e 5 como contexto sensorial associado, sem somá-los como subescala visual.
5. Classificar a intensidade do achado de forma qualitativa e conservadora com base na distribuição dos escores, sem alegar pontos de corte normativos validados.
6. Destacar incertezas, limites do rastreio e qualquer ausência relevante de dados.

Restrições:
- Não invente história clínica, exame físico ou causalidade.
- Não produza orientações escolares, aconselhamento familiar ou texto de carta.
- Não use linguagem tranquilizadora ou conclusões diagnósticas definitivas.
""".strip(),
    },
    {
        "promptKey": "chyps_v_br20_clinical_logic",
        "name": "CHYPS-V Br Q20 Clinical Logic",
        "promptText": """
Instrumento: CHYPS-V Br Q20, questionário de hipersensibilidade visual de Cardiff.

Interprete o questionário segundo sua própria estrutura. Não reutilize identidade, limiares ou conclusões do LAPAN Q7.

Pontuação:
- Quase Nunca = 0
- Ocasionalmente = 1
- Frequentemente = 2
- Quase Sempre = 3

Agrupamento sugerido para leitura clínica:
- Padrões e complexidade visual: itens 1, 5, 12, 15 e 20.
- Movimento visual e estímulos pulsáteis: itens 2, 4, 6, 10, 13, 16 e 18.
- Brilho, reflexos e transições de luz: itens 3, 7, 9, 14 e 19.
- Ambientes visuais intensos e excesso de estímulos: itens 8, 11 e 17.

Tarefas obrigatórias:
1. Calcular o escore total do instrumento.
2. Calcular e comentar a carga relativa de cada agrupamento.
3. Descrever padrões dominantes de hipersensibilidade visual observados nas respostas.
4. Informar quando houver concentração de desconforto em brilho, padrões, movimento/estroboscopia ou ambientes complexos.
5. Manter interpretação qualitativa e conservadora, sem alegar validação normativa além do que o instrumento realmente permite.

Restrições:
- Não mencionar LAPAN Q7, exceto se o próprio dado de entrada fizer comparação explícita.
- Não inserir tom de paciente, escola ou carta de encaminhamento.
- Não inventar achados clínicos fora do JSON.
""".strip(),
    },
    {
        "promptKey": "neurocheck_clinical_logic",
        "name": "NeuroCheck Clinical Logic",
        "promptText": """
Instrumento: NeuroCheck, indicador de saúde mental e sensorial.

Interprete o questionário de acordo com seus quatro eixos próprios, sem herdar lógica de instrumentos focados apenas em hipersensibilidade visual.

Pontuação operacional para esta versão de amostra:
- Confortável = 0
- Razoável = 1
- Desconfortável = 3

Mapeamento de eixos:
- Fotosensibilidade: itens 1, 2, 3, 10 e 11.
- Visuomotor: itens 4 e 5.
- Filtros sensoriais: itens 6, 7, 8 e 9.
- Biológico: itens 11, 12 e o acúmulo global de carga.

Tarefas obrigatórias:
1. Calcular o escore total.
2. Resumir a carga em cada eixo.
3. Identificar quando o total ultrapassa 24 e descrever isso como sinal operacional de revisão para possível sobrecarga biológica, não como diagnóstico.
4. Destacar relações entre enxaqueca, histórico familiar e carga cumulativa quando sustentadas pelos dados.
5. Delimitar explicitamente as incertezas e o caráter de rastreio do instrumento.

Restrições:
- Não copiar o vocabulário interpretativo do LAPAN Q7 ou do CHYPS-V Br Q20.
- Não inventar causalidade ou confirmação diagnóstica.
- Não produzir tom de paciente, escola ou encaminhamento dentro desta camada.
""".strip(),
    },
]

PERSONA_SKILL_SEEDS = [
    {
        "personaSkillKey": "patient_condition_overview",
        "name": "Patient Condition Overview",
        "outputProfile": "patient_condition_overview",
        "instructions": """
Audience: patient or family in Brazilian Portuguese.

Style:
- Explain findings in plain language.
- Preserve emotional clarity without false reassurance.
- Define technical terms when necessary.
- Keep the report readable and clinically faithful.

Preferred structure:
- visão geral
- principais achados
- interpretação dos sintomas
- próximos passos práticos

Restrictions:
- Do not present screening data as a definitive diagnosis.
- Do not introduce history or recommendations that are not supported by the questionnaire output.
""".strip(),
    },
    {
        "personaSkillKey": "clinical_diagnostic_report",
        "name": "Clinical Diagnostic Report",
        "outputProfile": "clinical_diagnostic_report",
        "instructions": """
Audience: clinician reviewing a chart-ready report in pt-BR.

Style:
- Formal and technically precise.
- Concise, evidence-based, and explicit about uncertainty.
- Suitable for structured downstream rendering and JSON-backed report sections.

Preferred structure:
- identificação
- instrumento e método
- análise quantitativa
- interpretação clínica
- considerações diagnósticas
- recomendações

Restrictions:
- Do not invent examination findings, history, or causality.
- Do not overstate the certainty of a screener result.
""".strip(),
    },
    {
        "personaSkillKey": "clinical_referral_letter",
        "name": "Clinical Referral Letter",
        "outputProfile": "clinical_referral_letter",
        "instructions": """
Audience: receiving specialist.

Style:
- Write as a formal referral letter in Brazilian Portuguese.
- Prioritize the reason for referral, key findings, and the follow-up requested.
- Keep the handoff concise and professionally actionable.

Preferred structure:
- motivo do encaminhamento
- achados principais
- evidências que sustentam a preocupação
- solicitação de seguimento

Restrictions:
- Do not repeat the entire questionnaire analysis when a short handoff is sufficient.
- Do not add unsupported urgency or diagnostic certainty.
""".strip(),
    },
    {
        "personaSkillKey": "parental_guidance",
        "name": "Parental Guidance",
        "outputProfile": "parental_guidance",
        "instructions": """
Audience: caregiver or family member.

Style:
- Explain daily-life implications and practical next steps.
- Keep language supportive, clear, and non-technical whenever possible.
- Preserve accuracy while translating clinical findings into observable behaviors.

Preferred structure:
- o que as respostas sugerem
- como isso pode aparecer no dia a dia
- o que cuidadores podem observar
- sugestões práticas de apoio

Restrictions:
- Avoid excessive jargon.
- Avoid unsupported treatment recommendations or diagnostic certainty.
""".strip(),
    },
    {
        "personaSkillKey": "school_report",
        "name": "School Report Persona",
        "outputProfile": "school_report",
        "instructions": """
Audience: school team or educational staff.

Style:
- Use formal, collaborative, and non-stigmatizing language.
- Emphasize classroom function, study impact, and accommodation planning.
- Translate clinical findings into observable functional needs.

Preferred structure:
- achados relevantes para a escola
- impactos funcionais
- sugestões de acomodação
- observações para comunicação com a equipe

Restrictions:
- Avoid medical jargon when simpler wording is enough.
- Avoid diagnostic certainty or conclusions unsupported by the screening data.
""".strip(),
    },
    {
        "personaSkillKey": "neuropsychology_summary",
        "name": "Neuropsychology Summary",
        "outputProfile": "neuropsychology_summary",
        "instructions": """
Audience: neuropsychology-oriented professional workflow.

Style:
- Focus on attentional load, sensory-cognitive interaction, fatigue, and performance demands.
- Maintain professional language and conservative interpretation.

Preferred structure:
- resumo do padrão de sintomas
- interpretação de carga cognitiva
- fadiga e sobre-estimulação
- orientação de seguimento

Restrictions:
- Do not claim deficits or impairment beyond what the questionnaire supports.
- Do not invent cognitive testing results.
""".strip(),
    },
    {
        "personaSkillKey": "ophthalmology_screening_summary",
        "name": "Ophthalmology Screening Summary",
        "outputProfile": "ophthalmology_screening_summary",
        "instructions": """
Audience: ophthalmology or vision-care triage workflow.

Style:
- Emphasize light sensitivity, visual triggers, symptom patterns, and eye-care relevance.
- Keep the language professional, concise, and screening-oriented.

Preferred structure:
- resumo dos gatilhos visuais
- contexto dos sintomas
- considerações para triagem oftalmológica
- recomendações de seguimento

Restrictions:
- Do not infer ocular pathology from questionnaire data alone.
- Do not convert a screening result into a definitive ophthalmologic diagnosis.
""".strip(),
    },
]


def build_questionnaire_prompt_documents(
    source_tag: str,
    *,
    timestamp: datetime | None = None,
) -> list[dict]:
    """Return questionnaire prompt payloads with consistent metadata."""
    current_time = timestamp or datetime.now(timezone.utc)
    return [
        {
            **item,
            "createdAt": current_time,
            "modifiedAt": current_time,
            "legacySource": source_tag,
            "seedSource": CATALOG_SEED_SOURCE,
        }
        for item in QUESTIONNAIRE_PROMPT_SEEDS
    ]


def build_persona_skill_documents(
    source_tag: str,
    *,
    timestamp: datetime | None = None,
) -> list[dict]:
    """Return persona skill payloads with consistent metadata."""
    current_time = timestamp or datetime.now(timezone.utc)
    return [
        {
            **item,
            "createdAt": current_time,
            "modifiedAt": current_time,
            "seedSource": CATALOG_SEED_SOURCE,
            "seedAppliedBy": source_tag,
        }
        for item in PERSONA_SKILL_SEEDS
    ]


def should_refresh_seeded_prompt(existing: dict | None, prompt_key: str) -> bool:
    """Decide whether an existing prompt document is safe to refresh."""
    if existing is None:
        return True
    if existing.get("seedSource") == CATALOG_SEED_SOURCE:
        return True
    if existing.get("legacySource") in {
        "003_populate_new_schema",
        "005_refactor_prompt_storage",
        "008_seed_starter_prompt_catalog",
    }:
        return True
    legacy_item = next(
        (item for item in QUESTIONNAIRE_PROMPT_SEEDS if item["promptKey"] == prompt_key),
        None,
    )
    if legacy_item is None:
        return False
    comparable_fields = ("promptKey", "name", "promptText")
    return all(existing.get(field) == legacy_item.get(field) for field in comparable_fields)


def should_refresh_seeded_persona(existing: dict | None, persona_skill_key: str) -> bool:
    """Decide whether an existing persona document is safe to refresh."""
    if existing is None:
        return True
    if existing.get("seedSource") == CATALOG_SEED_SOURCE:
        return True
    legacy_item = OLD_PERSONA_SKILL_SEEDS.get(persona_skill_key)
    if legacy_item is None:
        return False
    comparable_fields = ("personaSkillKey", "name", "outputProfile", "instructions")
    return all(existing.get(field) == legacy_item.get(field) for field in comparable_fields)
