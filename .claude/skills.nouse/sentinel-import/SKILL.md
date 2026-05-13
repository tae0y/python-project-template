---
name: sentinel-import
description: >
  Import Dev Sentinel experiences into localdocs/learn.sentinel.md.
  Use when the user wants to bring gotchas, failure lessons, or struggle experiences
  captured by Dev Sentinel into the project's local knowledge base.
  Triggers: "sentinel 가져와", "sentinel import", "gotcha 정리", "경험 가져와",
  "sentinel에서 배운 것", "실패 경험 가져와".
---

# Sentinel Import

Import confirmed experiences from Dev Sentinel CLI into `localdocs/learn.sentinel.md`.

## Workflow

### 1. Check Sentinel availability

```bash
which sentinel 2>/dev/null && sentinel status
```

If `sentinel` is not found, guide installation and stop:

```
Dev Sentinel CLI가 설치되어 있지 않아요. 설치 방법:

1. 소스 클론 (이미 있다면 건너뛰기):
   git clone https://github.com/elbanic/dev-sentinel.git

2. 빌드 및 글로벌 설치:
   cd dev-sentinel
   npm install && npm link

3. Ollama 모델 준비:
   ollama pull qwen3:4b
   ollama pull qwen3-embedding:0.6b

4. 이 프로젝트에서 초기화:
   cd <project-root>
   sentinel init

설치 후 다시 "sentinel 가져와"를 실행해주세요.
```

If sentinel is available but status shows 0 experiences and 0 drafts, inform user and stop.

### 2. Handle pending drafts first

```bash
sentinel review list
```

If pending drafts exist, ask user whether to confirm them first:
- `sentinel review confirm --all` to confirm all
- `sentinel review confirm --recent` to confirm latest only
- Skip to import only already-confirmed experiences

Confirming triggers LLM summarization (requires Ollama running).

### 3. List confirmed experiences

```bash
sentinel list
```

Show the list to the user. Ask which to import:
- All experiences
- Specific IDs
- Only new ones (not already in learn.sentinel.md)

### 4. Fetch detail for each selected experience

```bash
sentinel detail <id>
```

Capture these fields:
- **Issue** (frustrationSignature)
- **Failed Approaches** (what didn't work)
- **Successful Approach** (what solved it)
- **Lessons** (key takeaways)

### 5. Write to localdocs/learn.sentinel.md

Append each experience under a dated section. Follow this format:

```markdown
## YYYY-MM-DD

### <Issue title — concise, one line>

**ID:** `<sentinel-experience-id>`

**Failed approaches:**
- <approach 1>
- <approach 2>

**Solution:** <successful approach>

**Lessons:**
- <lesson 1>
- <lesson 2>
```

Rules:
- Create the file if it doesn't exist, with `# Sentinel Experiences` as heading
- Check existing content to avoid duplicating IDs already imported
- Append new experiences under today's date section
- Keep original Sentinel ID for traceability

### 6. Report result

```
Imported N experience(s) to localdocs/learn.sentinel.md
Skipped M already-imported experience(s)
```
