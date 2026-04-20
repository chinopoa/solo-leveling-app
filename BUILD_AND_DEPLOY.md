# Build & Deploy — Solo Leveling App

Cheat sheet for shipping a new IPA via Codemagic. Read top to bottom the first time, then just use the **Daily workflow** section.

---

## How it works (30-second mental model)

1. You write code on your Windows machine.
2. You commit and push to GitHub (`main` branch on `chinopoa/solo-leveling-app`).
3. Codemagic detects the push, clones the repo on a Mac mini, runs `flutter build ios`, packages an unsigned IPA, and emails it to you.
4. Codemagic only ever sees what's on GitHub. **Anything not pushed is invisible to it.** That's why every build cycle starts with a push.

---

## One-time setup (skip if already done)

### GitHub authentication

GitHub disabled password auth in 2021. You need one of:

**Option A — Personal Access Token (easiest on Windows)**
1. Go to https://github.com/settings/tokens → "Generate new token (classic)"
2. Scope: tick `repo` (full control of private repos)
3. Expiration: 90 days or longer
4. Copy the token (starts with `ghp_…`) — you'll never see it again
5. First time you `git push`, Windows Credential Manager will prompt — paste the token as the **password**, your GitHub username (`chinopoa`) as the username
6. Credential Manager remembers it; subsequent pushes are silent

**Option B — GitHub CLI**
1. Install from https://cli.github.com/
2. Run `gh auth login` and follow prompts
3. `gh` becomes the credential helper automatically

**Option C — SSH key**
1. `ssh-keygen -t ed25519 -C "chinooknao@gmail.com"`
2. Add `~/.ssh/id_ed25519.pub` to https://github.com/settings/keys
3. Switch the remote: `git remote set-url origin git@github.com:chinopoa/solo-leveling-app.git`

If push ever fails with `Invalid username or token`, your token expired — generate a new one (Option A) and update Credential Manager (Windows → search "Credential Manager" → Windows Credentials → find `git:https://github.com` → edit).

### Codemagic connection

Already done — the project at https://codemagic.io is wired to this GitHub repo and watches the `main` branch. The build config lives in [codemagic.yaml](codemagic.yaml) at the repo root.

---

## Daily workflow (the part you'll actually use)

From the project folder `c:\Users\bleac\sl\solo_leveling_app`:

```bash
# 1. See what changed
git status

# 2. Stage all the files you want in this build
git add .
# (or be specific: git add lib/screens/workout_screen.dart lib/providers/game_provider.dart)

# 3. Commit with a message describing what you did
git commit -m "Short description of what changed"

# 4. Push to GitHub — this is what triggers the Codemagic build
git push origin main
```

That's it. Now go to https://codemagic.io/apps and watch the build run (≈8–15 minutes). When it finishes, the IPA lands in your email at `chinooknao@gmail.com`.

### Trigger a build manually (no code changes)

If a build failed for environment reasons and you want to retry without changing code: open the project in Codemagic → "Start new build" → pick `main` → "Start new build". No push needed.

---

## Installing the IPA on your iPhone

The build is unsigned (`--no-codesign`), so you need a sideloading tool:

- **AltStore** (free, requires AltServer running on your PC) — https://altstore.io
- **Sideloadly** (free) — https://sideloadly.io
- Plug iPhone in, drag the `.ipa` into the tool, sign with your Apple ID, install

Sideloaded apps expire every 7 days (Apple ID limit) and need re-signing — that's an Apple restriction, not a Codemagic one. To get around it, you'd need a paid Apple Developer account ($99/year) and to set up code signing in [codemagic.yaml](codemagic.yaml).

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Authentication failed` on push | Token expired or never set | Regenerate PAT (Option A above), update Windows Credential Manager |
| Codemagic build doesn't start after push | Auto-trigger disabled, or pushed to wrong branch | Check Codemagic → app → "Triggers" tab; verify push went to `main` (`git log origin/main` should show your commit) |
| Build fails on `flutter pub get` | Dependency mismatch from local-only changes | Run `flutter pub get` locally, commit any updated `pubspec.lock` |
| Build fails on Xcode step | Usually iOS deployment target / pod issues | Check the Codemagic log for the Xcode error, often a quick `pod` or `Info.plist` fix |
| IPA installs but crashes on launch | Hive typeId conflict (we've hit this before) | Check `lib/models/*.dart` for duplicate `@HiveType(typeId: N)` |
| "Your branch is ahead of origin/main by N commits" | Local commits never pushed | `git push origin main` |

---

## Quick reference — the only commands that matter

```bash
git status                     # what's changed
git diff                       # see the actual changes
git add .                      # stage everything
git commit -m "message"        # save the snapshot
git push origin main           # send to GitHub → triggers Codemagic
git log --oneline -5           # see recent commits
```
