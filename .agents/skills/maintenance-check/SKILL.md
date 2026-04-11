---
name: maintenance-check
description: Inspect this nix config and report what would likely change in a system update without applying it
---

Use this skill when the user asks what would get updated, what changed upstream, whether an update looks safe, or wants a maintenance preview before changing anything.

This skill may update `flake.lock` during preview. Do not switch the system.

The user is often after the same kind of answer that `nh os switch` gives: which packages would be added, updated, or removed. Prefer that evaluated package-diff view when the user wants a concrete system-impact answer rather than only an input-level preview.

Also surface evaluation warnings. The warnings are part of the maintenance picture, not just noise.

## Goal

Produce a concise operator-style summary that fits roughly on one screen:
- what user-facing packages would likely be added, updated, or removed on the target host
- which evaluation warnings appeared
- which easy cleanup items should be fixed before updating
- which standout update deserves special attention
- which hosts or workflows are likely affected
- what the next two reasonable actions are

## Default workflow

Unless the user explicitly asks for a lightweight input-only preview, do this exact flow:

1. Inspect `git status --short`.
   - If the worktree is dirty, state that clearly before running anything.
2. Run the in-repo dry update preview:
   - `XDG_CACHE_HOME=/tmp/nix-cache-preview nh os switch -n -d always -u .`
   - If a host is named, pass `--hostname <host>`.
3. Use the `nh` output as the source of truth for package changes.
   - Accept that `flake.lock` may be updated.
   - Do not try temporary flake copies, `--override-input`, or `nh --no-write-lock-file` by default.
4. Filter the package list aggressively.
   - Keep user-facing packages and directly meaningful tools/apps/services.
   - Drop low-signal rebuild churn unless it is security-sensitive, boot-critical, or likely user-visible.
5. Report using the strict template below.

## Lightweight mode

Only use this when the user explicitly asks about inputs rather than package impact:
- build a temporary preview of updates instead of touching the repo lockfile
- use a temporary directory
- copy in `flake.nix` and `flake.lock`
- run `nix flake update` there
- diff temporary `flake.lock` against the real one

## What to mention in the summary

- `nixpkgs`, `home-manager`, `stylix`, `nixos-hardware`, `sops-nix`, `nixos-wsl`, `deploy-rs`
- developer-facing inputs such as `opencode`, `claude-code`, `walker`, `zen-browser`
- any input on a PR ref, fork, or custom branch
- release-note or changelog links for important user-facing software when available
- likely host impact:
  - local machine build path via `scripts/test-build`
  - remote path via `scripts/update --remote --hostname=<host>`

## Boundaries

- Do not do a real switch.
- Default to the in-repo `nh os switch -n -d always -u .` dry preview for package-level answers.
- Do not present raw lockfile noise unless the user asked for it. Summarize likely impact first.
- Do not dump the entire `CHANGED` section when much of it is low-level rebuild churn.

## Heuristics

- Treat `nixpkgs`, `home-manager`, and `stylix` as broader-risk updates.
- Treat forks, PR refs, and custom branches as review-required updates.
- Treat tool-only inputs as narrower risk unless they are wired into shared modules.
- Use the lockfile preview only for explicit input-level questions.
- Use the evaluated `nh` dry diff by default when the user wants closure-level impact or package version changes.
- Treat warnings with explicit option assignments or straightforward renames as easy.
  - examples:
    - `gtk.gtk4.theme = config.gtk.theme;` or `null`
    - `programs.neovim.withRuby = true/false`
    - `programs.neovim.withPython3 = true/false`
    - rename `swww` to `awww`
    - switch from `nixfmt-classic` to `nixfmt`
- Treat warnings that imply package replacements, module redesign, or behavior changes across multiple hosts as hard.
- Treat these as usually interesting and worth listing:
  - browsers, editors, terminals, shells
  - AI/dev tools such as `opencode`, `claude-code`, `codex`, `graphite-cli`, `cursor`, `lmstudio`, `worktrunk`
  - core desktop components the user will notice such as `plasma-*`, `xdg-desktop-portal`, `hypr*`, `waybar`, `pipewire`, `flatpak`
  - Nix tooling such as `nix`, `home-manager`, `nh`
  - host/service unit additions or removals when they reflect config behavior changes
- Include release-note or changelog links for user-facing software where they can realistically inform the operator decision.
  - Prioritize official sources.
  - Prioritize packages such as `claude-code`, `opencode`, `cursor`/VS Code, `hyprland`, `alacritty`, `ghostty`, `neovim`, browsers, and notable CLIs.
  - Do not add links for low-signal library churn.
- If one update is materially bigger than the rest, give it its own section instead of burying it in the routine list.
  - `cursor` major-version jumps are the canonical example.
- Treat these as usually uninteresting and omit unless they explain a visible change:
  - generic libraries (`lib*`)
  - codec and media internals
  - graphics stack internals
  - duplicated split outputs (`-dev`, `-man`, `-doc`, `-lib`, `-sandbox`, `-terminfo`)
  - mass rebuilds marked only as changed without a meaningful version bump
- If the worktree is dirty, suggest stashing or committing unrelated changes before a real update.
- Keep the most actionable items near the bottom of the response, not the top.
- Avoid filler explanations like "direct flake input update for your AI CLI tool." If a sentence does not change the operator decision, cut it.

## Response template

Use this exact structure for package-impact answers:

```md
Worktree: `<clean|dirty>`
Note: <One-line note if dirty or if `flake.lock` changed during preview. Omit when not needed.>

Host: `<host>`
Preview: `XDG_CACHE_HOME=/tmp/nix-cache-preview nh os switch -n -d always -u .`

Routine updates
- `<package>` `<old> -> <new>` ([notes](<url>))
- ...

Added/removed units or packages
- Added: `<item>`
- Removed: `<item>`

<Optional standout section title, e.g. `Cursor`>
- `<package>` `<old> -> <new>`
- <one short sentence about why this one is separate>
- <release-note or changelog link when available>

Warnings
| Type | Warning | Fix |
|---|---|---|
| Easy | `<warning>` | `<short remediation>` |
| Check after update | `<warning>` | `<short validation note>` |

Next steps
1. Update now: <short operator framing>
2. Fix easy warnings first, then update: <short operator framing>
```

Rules for the template:
- Keep the response concise enough to fit on one screen.
- Keep `Routine updates` focused on user-facing changes.
- Put the most important items closer to the bottom: standout update, warnings, then next steps.
- If there are no meaningful additions or removals, write `Added/removed units or packages` with `- None worth calling out.`
- Do not include a separate raw input-update section unless the user asked for it.
- Include release-note links for important user-facing software when available; skip them for low-signal churn.
- Do not include a `Risk` section.
- Keep the whole response concise and operator-oriented.
