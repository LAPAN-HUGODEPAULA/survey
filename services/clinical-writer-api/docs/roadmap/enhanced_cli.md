# Roadmap: Enhanced CLI with Typer

## Current Issue

The `main.py` is primarily a web service. A powerful CLI would be beneficial for local development, testing, and batch processing.

## Recommendation

Use a library like [Typer](https://typer.tiangolo.com/) or [Click](https://click.palletsprojects.com/) to create a more feature-rich CLI.

```python
# src/cli.py
import typer
from clinical_writer_agent.src.agent_graph import clinical_writer_graph, _default_observer

app = typer.Typer()

@app.command()
def process(file_path: str):
    """Process a clinical data file and print the generated record."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    state = {"input_content": content, "observer": _default_observer}
    final_state = clinical_writer_graph.invoke(state)
    
    if final_state.get("error_message"):
        typer.secho(f"Error: {final_state['error_message']}", fg=typer.colors.RED)
    else:
        typer.echo(final_state["medical_record"])

if __name__ == "__main__":
    app()
```

## Benefits

-   **User-Friendly:** Provides a better command-line experience with auto-generated help messages.
-   **Structured Commands:** Makes it easy to add more commands and options in the future.
-   **Productivity:** Improves developer workflow for testing and interaction with the agent.

## Priority

**Low** (but a nice-to-have for developer experience)
