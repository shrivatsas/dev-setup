---
name: codex
description: Use OpenAI Codex CLI for complex debugging, code analysis, or when stuck on difficult problems. Invokes Codex with a file-based question/answer pattern.
disable-model-invocation: true
---

# Using Codex for Complex Debugging

When you encounter a difficult problem that would benefit from a second perspective or deep analysis, use Codex via the file-based pattern.

## When to Use

- Debugging subtle bugs (bitstream alignment, off-by-one errors)
- Analyzing complex algorithms against specifications
- Getting detailed code review with specific bug identification
- Understanding obscure file formats or protocols
- When you've tried multiple approaches and are stuck

## The Pattern

### Step 1: Create a Question File

Write to `/tmp/question.txt` with:
- Clear problem statement
- The specific error or symptom
- The relevant code (full functions, not snippets)
- What you've already tried
- Specific questions you want answered
- Request: "Please write a detailed analysis to /tmp/reply.txt"

Example structure:
```
I have a [component] that fails with [specific error].

Here is the full function:
[paste complete code]

Key observations:
1. [What works]
2. [What fails]
3. [When it fails]

Can you identify:
1. [Specific question 1]
2. [Specific question 2]

Please write a detailed analysis to /tmp/reply.txt
```

### Step 2: Invoke Codex

```bash
cat /tmp/question.txt | codex exec --full-auto
```

Flags:
- `exec`: Non-interactive execution mode (required for CLI use)
- `--full-auto`: Run autonomously without prompts

Do NOT use the `-o` flag. The prompt already instructs Codex to write its analysis to `/tmp/reply.txt` via its own shell commands. Using `-o /tmp/reply.txt` would overwrite the actual analysis with Codex's conversational stdout (e.g. "Wrote the analysis...").

### Step 3: Read the Reply

Read `/tmp/reply.txt` and evaluate suggestions critically. Codex may identify real bugs but can occasionally misinterpret specifications.

## Tips

1. **Provide complete code**: Don't truncate functions. Codex needs full context.
2. **Be specific**: "Why does Huffman decoding fail after 1477 blocks?" > "Why does this fail?"
3. **Include the spec**: Mention relevant spec sections if debugging against a standard.
4. **Verify suggestions**: Codex is helpful but not infallible. Always verify against authoritative sources.
5. **Iterate if needed**: Create a new question.txt with additional context if first response doesn't solve the problem.

## Common Issues

- **"stdin is not a terminal"**: Use `codex exec` not bare `codex`
- **No output**: Check that `-o` flag has a valid path
- **Timeout**: Complex questions take time; `--full-auto` avoids blocking prompts

## Quick Alternative

For shorter questions:
```bash
echo "Explain the JPEG progressive AC refinement algorithm" | codex exec --full-auto
```

But for debugging, the file-based pattern is better for refining questions and keeping records.

