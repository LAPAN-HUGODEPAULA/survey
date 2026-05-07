from clinical_writer_agent.prompts import ConversationPrompts, JsonPrompts


def test_conversation_prompt_includes_content():
    content = "Doutor: tudo bem com o paciente?"
    prompt = ConversationPrompts.build_medical_record_prompt(content)
    assert content in prompt
    assert "assistente de escrita clínica" in prompt


def test_json_prompt_includes_content():
    content = '{"patient": {"name": "Ana", "age": 17}}'
    prompt = JsonPrompts.build_medical_record_prompt(content)
    assert content in prompt
    assert "GERE APENAS O LAUDO MÉDICO" in prompt
