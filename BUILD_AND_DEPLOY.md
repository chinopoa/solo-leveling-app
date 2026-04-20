# Build & Deploy — Solo Leveling App

Cheat sheet for shipping a new IPA via Codemagic. Read top to bottom the first time, then just use the **Daily workflow** section.

---

## How it works (30-second mental model)

1. You write code on your Windows machine.
2. You commit and push to GitHub (`main` branch on `chinopoa/solo-leveling-app`).
3. Codemagic detects the push, clones the repo on a Mac mini, runs `flutter build ios`, packages an unsigned IPA, and emails it to you at `chinooknao@gmail.com`.
4. Codemagic only ever sees what's on GitHub. **Anything not pushed is invisible to it.** That's why every build cycle starts with a push.

---

## Daily workflow (the part you'll actually use)

From the project folder `c:\Users\bleac\sl\solo_leveling_app`:

```bash
git status                      # see what changed
git add .                       # stage everything
git commit -m "what changed"    # save the snapshot
git push origin main            # send to GitHub → triggers Codemagic
```

That's it. Now go to https://codemagic.io/apps and watch the build run (≈8–15 minutes). When it finishes, the IPA lands in your email.

### Trigger a build manually (no code changes)

If a build failed for environment reasons and you want to retry without changing code: open the project in Codemagic → "Start new build" → pick `main` → "Start new build". No push needed.

---

## GitHub authentication on this machine

Your machine uses **Git Credential Manager (GCM)** — it ships with Git for Windows. First push opens a browser/account picker; you click your GitHub account and it remembers you.

### When the picker doesn't pop up (the gotcha we hit)

If `git push` fails with one of these:
- `Permission to chinopoa/solo-leveling-app.git denied to <other-user>` → GCM cached a different GitHub account's credential
- `Invalid username or token` → cached token expired

GCM is silently using the wrong/stale credential instead of prompting. Purge it and retry:

```bash
printf "protocol=https\nhost=github.com\n\n" | git credential-manager erase
git push origin main
```

The picker will pop up — click `chinopoa`. Done.

If that doesn't work, open Windows Credential Manager (Win key → search "Credential Manager") → Windows Credentials tab → find any entry like `git:https://github.com` and delete it → push again.

### Don't embed the username in the remote URL

The remote should be `https://github.com/chinopoa/solo-leveling-app.git`, **not** `https://chinopoa@github.com/chinopoa/...`. The embedded `chinopoa@` form makes GCM use a per-username credential slot which gets stuck on stale tokens. Check with:

```bash
git remote -v
# if it has chinopoa@ in there:
git remote set-url origin https://github.com/chinopoa/solo-leveling-app.git
```

### Codemagic connection

Already done — the project at https://codemagic.io is wired to this GitHub repo and watches the `main` branch. Build config lives in [codemagic.yaml](codemagic.yaml) at the repo root.

---

## Installing the IPA on your iPhone

The build is unsigned (`--no-codesign`), so you need a sideloading tool:

- **AltStore** (free, requires AltServer on your PC) — https://altstore.io
- **Sideloadly** (free) — https://sideloadly.io

Plug iPhone in, drag the `.ipa` into the tool, sign with your Apple ID, install.

Sideloaded apps expire every 7 days (Apple ID limit) and need re-signing — that's an Apple restriction, not a Codemagic one. To get around it, you'd need a paid Apple Developer account ($99/year) and to set up code signing in [codemagic.yaml](codemagic.yaml).

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Permission denied to <other-user>` on push | GCM cached wrong account | Run the `git credential-manager erase` command above |
| `Invalid username or token` on push | Cached token expired | Same fix — erase and re-push, picker reappears |
| Codemagic build doesn't start after push | Auto-trigger disabled, or pushed to wrong branch | Codemagic → app → "Triggers" tab; verify push went to `main` (`git log origin/main` should show your commit) |
| Build fails on `flutter pub get` | Dependency mismatch from local-only changes | Run `flutter pub get` locally, commit the updated `pubspec.lock` |
| Build fails on Xcode step | iOS deployment target / pod issues | Check Codemagic log for the Xcode error — usually a quick `Info.plist` or `Podfile` fix |
| IPA installs but crashes on launch | Hive `typeId` conflict (we've hit this before) | Check `lib/models/*.dart` for duplicate `@HiveType(typeId: N)` |
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
git remote -v                  # confirm remote URL is correct
```
