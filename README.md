# FitStart — Project Structure (initial commit)

This is the **project structure only** — no feature implementations yet.
Every `lib/features/<name>/` folder follows clean architecture
(`domain/`, `data/`, `presentation/`) and is currently empty (just
`.gitkeep` placeholders). This is meant to be the very first commit; each
team member then builds their assigned features on top of this on their
own branch.

## Structure
- `lib/main.dart` — minimal placeholder app (just runs, nothing built yet)
- `lib/app/` — theme + router (to be filled in by Gimantha)
- `lib/core/` — shared di / error / widgets (shared, coordinate before editing)
- `lib/features/<name>/` — one folder per feature, empty skeleton

## Before building
1. Run `flutter pub get`
2. Run `flutterfire configure` to generate your own `lib/firebase_options.dart`
   (not included in this repo — it holds real API keys and is gitignored)
3. Add `android/app/google-services.json` (get from Firebase Console —
   also gitignored, not in this repo)

## Team split & branches
See the team task-split doc shared separately for who owns which
`lib/features/` folder and each person's branch name.
