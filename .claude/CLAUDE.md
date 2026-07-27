This is a flutter project the powers the VFX GUI

Website: https://verifiedx.io/
Docs: https://docs.verifiedx.io/
CORE CLI Code: https://github.com/VerifiedXBlockchain/VerifiedX-Core
Web Wallet / Explorer Code: https://github.com/VerifiedXBlockchain/VerifiedX-SpyglassService

Something to point out is that this both powers the desktop GUI as well as the web wallet. The web wallet is quite a lot different since it doesn't speak to a CLI directly. Instead, it works through an API that has the data already normalized. It also manages it's own key generation.

This project uses fvm so all flutter/dart commands need to be prefixed with that.

<!-- polaris:start -->
## Polaris

> Hand-maintained. The default Polaris flutter profile is Django-paired and does not fit this project; the generic templates have been removed.

### Stack at a glance

- Flutter 3.7.12 via **fvm** — always prefix flutter/dart commands with `fvm`
- Riverpod (legacy `StateNotifier` + new `@Riverpod` codegen, both coexist), freezed, auto_route, Dio
- Desktop target: talks to the VerifiedX **Core CLI** spawned as a local subprocess over localhost HTTP
- Web target (wallet/explorer): talks to the **Spyglass API**, manages its own key generation, uses Hive for storage
- Dual routers (`AppRouter`, `WebRouter`) selected at runtime via `Env.isWeb`

### Project context (the real source of truth)

Read these before implementing or reviewing — they describe **this** project, not a template:

- `context/ROUTER.md` — pick the right files for your task
- `context/architecture.md` — stack, structure, entry points
- `context/decisions.md` — why things are the way they are
- `context/conventions.md` — naming, state management, error handling, dialogs, platform branching
- `context/patterns/` — reusable solutions captured over time

Use `/recall` at session start, `/remember` to capture new decisions/conventions, and `/intel` to refresh the scaffold.

**Agents:**
- `agents/executor.md` — Agent: Executor (generic, stack-agnostic)
<!-- polaris:end -->


<!-- OCR:START -->
# Open Code Review Instructions

These instructions are for AI assistants handling code review in this project.

Always open `.ocr/skills/SKILL.md` when the request:
- Asks for code review, PR review, or feedback on changes
- Mentions "review my code" or similar phrases
- Wants multi-perspective analysis of code quality
- Asks to map, organize, or navigate a large changeset

Use `.ocr/skills/SKILL.md` to learn:
- How to run the 8-phase review workflow
- How to generate a Code Review Map for large changesets
- Available reviewer personas and their focus areas
- Session management and output format

Keep this managed block so 'ocr init' can refresh the instructions.

<!-- OCR:END -->