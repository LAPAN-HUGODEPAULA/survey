# Installation and Maintenance

## Quick Verification

```bash
# Check all files compile
cd /home/hugo/Documents/PostDoc/clinical_writer/clinical_writer_agent
python3 -m py_compile src/*.py
# Output: ✅ All files compiled successfully!

# Run the application
uvicorn src.main:app --reload
```

## Configuration Setup

Ensure your `.env` file exists with:

```
GEMINI_API_KEY=your_actual_api_key_here
```

## Project Structure (Updated)

```
clinical_writer_agent/
├── src/
│   ├── agent_config.py          ⭐ NEW - Centralized configuration
│   ├── agent_graph.py            ✏️ MODIFIED - Uses config constants
│   ├── agent_state.py            (unchanged)
│   ├── conversation_processor_agent.py  ✏️ MODIFIED - Dependency injection
│   ├── json_processor_agent.py   ✏️ MODIFIED - Dependency injection
│   ├── input_validator.py        ✏️ MODIFIED - Uses config
│   ├── other_inputs_handler.py   ✏️ MODIFIED - Uses config
│   ├── main.py                   (unchanged)
│   ├── bad_word.txt              (unchanged)
│   └── slangs.txt                (unchanged)
```