# Architecture Summary

See `.claude/context/` for the full context scaffold:
- `context/architecture.md` — stack, structure, constraints, entry points
- `context/decisions.md` — architectural decisions with rationale
- `context/conventions.md` — naming, file org, error handling, state management norms

Use `context/ROUTER.md` to find what to load for your current task.

## Quick Reference
- **Flutter 3.7.12** via FVM, Riverpod + freezed + auto_route + Dio
- **Desktop**: localhost CLI communication, SharedPreferences
- **Web**: remote API (data.verifiedx.io), Hive storage, own key management
- **Features**: 55 modules in `lib/features/`, each with screens/components/providers/models/services
- **Env**: mainnet/testnet/devnet via CLI args (desktop) or dart-define (web)
- **Codegen**: `fvm flutter packages pub run build_runner build --delete-conflicting-outputs`
