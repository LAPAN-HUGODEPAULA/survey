from clinical_writer_agent.prompts import ConversationPrompts, JsonPrompts


def test_conversation_prompt_includes_content():
    content = "Doutor: tudo bem com o paciente?"
    prompt = ConversationPrompts.build_medical_record_prompt(content)
    assert content in prompt
    assert prompt.startswith("Generate a clinical record from the following conversation:")


def test_json_prompt_includes_content():
    content = '{"patient": {"name": "Ana", "age": 17}}'
    prompt = JsonPrompts.build_medical_record_prompt(content)
    assert content in prompt
    assert "following JSON data" in prompt
