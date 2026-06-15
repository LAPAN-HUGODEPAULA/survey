#!/usr/bin/env python3
"""
sync_agent_configs.py

Synchronizes agent configurations, custom skills, and workflows across:
- Antigravity CLI (.agent/)
- Claude Code (.claude/)
- Google Gemini CLI (.gemini/)
- Cursor AI (.cursor/)
- OpenAI Codex (.codex/)

Author: Hugo de Paula
"""

import os
import re
import sys

# Paths relative to the project root
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
AGENT_DIR = os.path.join(ROOT_DIR, ".agent")
CLAUDE_DIR = os.path.join(ROOT_DIR, ".claude")
GEMINI_DIR = os.path.join(ROOT_DIR, ".gemini")
CURSOR_DIR = os.path.join(ROOT_DIR, ".cursor")
CODEX_DIR = os.path.join(ROOT_DIR, ".codex")

WORKFLOWS_SRC_DIR = os.path.join(AGENT_DIR, "workflows")
SKILLS_SRC_DIR = os.path.join(AGENT_DIR, "skills")


def ensure_symlink(target, link_name):
    """Ensures a symbolic link exists and points to the correct target."""
    target_abs = os.path.abspath(os.path.join(os.path.dirname(link_name), target))
    if not os.path.exists(target_abs):
        print(f"Error: Target path '{target_abs}' does not exist.", file=sys.stderr)
        return False

    if os.path.islink(link_name):
        current_target = os.readlink(link_name)
        if current_target == target:
            return True
        print(f"Removing incorrect symlink '{link_name}' -> '{current_target}'")
        os.unlink(link_name)
    elif os.path.exists(link_name):
        if os.path.isdir(link_name):
            import shutil
            print(f"Removing directory '{link_name}' to make room for symlink")
            shutil.rmtree(link_name)
        else:
            print(f"Removing file '{link_name}' to make room for symlink")
            os.remove(link_name)

    # Ensure parent directory exists
    os.makedirs(os.path.dirname(link_name), exist_ok=True)
    os.symlink(target, link_name)
    print(f"Created symlink: {link_name} -> {target}")
    return True


def parse_workflow_file(filepath):
    """Parses frontmatter and body of a markdown workflow file."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Split by the frontmatter delimiter
    parts = re.split(r"^---\s*$", content, flags=re.MULTILINE)
    if len(parts) >= 3:
        frontmatter_raw = parts[1]
        body = parts[2].strip()
    else:
        frontmatter_raw = ""
        body = content.strip()

    frontmatter = {}
    for line in frontmatter_raw.strip().split("\n"):
        if ":" in line:
            k, v = line.split(":", 1)
            frontmatter[k.strip()] = v.strip().strip('"').strip("'")

    return frontmatter, body


def sync_workflows():
    """Syncs workflows from .agent/workflows to other agent configurations."""
    if not os.path.exists(WORKFLOWS_SRC_DIR):
        print(f"Source workflows directory '{WORKFLOWS_SRC_DIR}' does not exist.")
        return

    # Target directories
    claude_cmd_dir = os.path.join(CLAUDE_DIR, "commands", "opsx")
    cursor_cmd_dir = os.path.join(CURSOR_DIR, "commands")
    gemini_cmd_dir = os.path.join(GEMINI_DIR, "commands", "opsx")

    os.makedirs(claude_cmd_dir, exist_ok=True)
    os.makedirs(cursor_cmd_dir, exist_ok=True)
    os.makedirs(gemini_cmd_dir, exist_ok=True)

    for filename in os.listdir(WORKFLOWS_SRC_DIR):
        if not filename.endswith(".md"):
            continue

        src_path = os.path.join(WORKFLOWS_SRC_DIR, filename)
        frontmatter, body = parse_workflow_file(src_path)

        # Derive names and IDs
        base_name = filename.replace("opsx-", "").replace(".md", "")
        
        # Determine metadata defaults
        name = frontmatter.get("name", f"OPSX: {base_name.capitalize()}")
        description = frontmatter.get("description", "")
        category = frontmatter.get("category", "Workflow")
        tags = frontmatter.get("tags", "[workflow, experimental]")
        workflow_id = frontmatter.get("id", f"opsx-{base_name}")

        # 1. Sync to Claude Code (.claude/commands/opsx/base_name.md)
        claude_path = os.path.join(claude_cmd_dir, f"{base_name}.md")
        claude_content = f"""---
name: "{name}"
description: {description}
category: {category}
tags: {tags}
---

{body}
"""
        with open(claude_path, "w", encoding="utf-8") as f:
            f.write(claude_content)
        print(f"Synced Claude command: {claude_path}")

        # 2. Sync to Cursor (.cursor/commands/opsx-base_name.md)
        cursor_path = os.path.join(cursor_cmd_dir, f"opsx-{base_name}.md")
        cursor_content = f"""---
name: /{workflow_id}
id: {workflow_id}
category: {category}
description: {description}
---

{body}
"""
        with open(cursor_path, "w", encoding="utf-8") as f:
            f.write(cursor_content)
        print(f"Synced Cursor command: {cursor_path}")

        # 3. Sync to Google Gemini (.gemini/commands/opsx/base_name.toml)
        gemini_path = os.path.join(gemini_cmd_dir, f"{base_name}.toml")
        
        # Escape double quotes in body for TOML multi-line string
        escaped_body = body.replace('\\', '\\\\').replace('"""', '\\"\\"\\"')
        gemini_content = f"""description = "{description}"

prompt = \"\"\"
{escaped_body}
\"\"\"
"""
        with open(gemini_path, "w", encoding="utf-8") as f:
            f.write(gemini_content)
        print(f"Synced Gemini command: {gemini_path}")


def main():
    print("Starting agent configuration synchronization...")

    # Phase 1: Enforce Guideline Symlinks
    print("\n--- Phase 1: Guidelines Symlinks ---")
    ensure_symlink("AGENTS.md", os.path.join(ROOT_DIR, "CLAUDE.md"))
    ensure_symlink("AGENTS.md", os.path.join(ROOT_DIR, "GEMINI.md"))
    ensure_symlink("../AGENTS.md", os.path.join(ROOT_DIR, ".github", "copilot-instructions.md"))

    # Phase 2: Enforce Skills Symlinks
    print("\n--- Phase 2: Skills Symlinks ---")
    ensure_symlink("../.agent/skills", os.path.join(CLAUDE_DIR, "skills"))
    ensure_symlink("../.agent/skills", os.path.join(CODEX_DIR, "skills"))
    ensure_symlink("../.agent/skills", os.path.join(GEMINI_DIR, "skills"))
    ensure_symlink("../.agent/skills", os.path.join(CURSOR_DIR, "skills"))
    ensure_symlink("../.agent/skills", os.path.join(ROOT_DIR, ".github", "skills"))

    # Phase 3: Sync Workflows/Commands
    print("\n--- Phase 3: Sync Workflows ---")
    sync_workflows()

    print("\nAgent configurations synchronization complete!")


if __name__ == "__main__":
    main()
