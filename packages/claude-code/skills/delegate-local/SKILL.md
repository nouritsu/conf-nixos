---
name: delegate-local
description: Hand well-scoped, mechanical code edits to the local Qwen model through opencode, then review its diff. Use for bulk or repetitive work (one pattern across many files, boilerplate, renames, long generated output) or when the user asks for the local model. Not for open-ended design, debugging, or small one-off edits that are cheaper to make directly.
---

# Delegate edits to the local model

The local model runs behind llama-swap on `127.0.0.1:8080` (pc only). The `local` opencode agent can read, search and edit files inside its working directory. It has no shell, web or MCP access.

| Model | When |
| --- | --- |
| `llama-swap/qwen3.6-35b-a3b` (default) | most edits, 64k context |
| `llama-swap/qwen3.5-9b` | trivial edits when speed matters, 32k context |

## Steps

1. Check the server: `curl -sf http://127.0.0.1:8080/health`. If it fails, do the work yourself and say why.
2. Run `git status` so you can tell the model's changes from the user's.
3. Write the task. Small models need it spelled out:
   - exact file paths to touch, and that nothing else may change
   - the pattern as a concrete before/after snippet
   - constraints (keep formatting and comments, match surrounding style)
   - "When finished, reply with the list of files you changed."
4. Run it from the project root with a 10 minute Bash timeout, or in the background:

   ```bash
   opencode run --agent local --dir "$PWD" "<task>"
   ```

   Add `-m llama-swap/qwen3.5-9b` for the small model. A cold start loads the model first (about a minute; the first run ever also downloads it).
5. Review every hunk with `git diff`. Fix wrong hunks yourself with Edit. Never discard changes that were already there in step 2.
6. Tell the user what the local model changed and what you corrected.

## Sizing

Split big jobs into several runs of a few files each. If a run goes off track twice, stop delegating that task and do it yourself.
