import sys

from clinical_writer_agent.prompt_registry import create_prompt_registry


def main() -> int:
    prompt_key = sys.argv[1] if len(sys.argv) > 1 else "default"
    registry = create_prompt_registry()
    prompt_text, version = registry.get_prompt(prompt_key)
    print(f"prompt_key={prompt_key}")
    print(f"prompt_version={version}")
    print(f"prompt_length={len(prompt_text)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
