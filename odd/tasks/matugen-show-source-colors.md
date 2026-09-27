# Feature: Quickshell ThemingPage — matugen source colors

## Objective
In the Theming settings page, show the candidate source colors that matugen
extracts from the current wallpaper (`matugen image <path> --show-source-colors`)
as selectable swatches, and make the source color index selector functional.

## Problem / Why
- The "Matugen source color index" numeric selector is non-operative:
  `colours.sourceColorIndex` is not declared in the `colours` JsonObject of
  `Config.qml` (only enableScheme/genType/mode/useCustom are), so the key is not
  reactive and does not persist reliably through the JsonAdapter.
- The user must know which colors each index refers to; only a raw number is shown.

## Evidence (verified 2026-09-27)
- `matugen 4.2.0` installed: `--show-source-colors` prints candidates, one
  `#rrggbb` line per color, non-destructive, exit 0. Tested with `in.JPG`.
- `--source-color-index <0..4>` valid; an index with no candidate (e.g. 3 with
  2 candidates) exits 1 ("Could not get source color").
- `services/Wallpaper.qml getMatugenArgs()` already passes
  `--source-color-index` from Config key `colours.sourceColorIndex`.
- Live shell runs from `~/.config/quickshell`; deploy via `scripts/sync-quickshell.sh`
  (preserves runtime state, no --delete).

## Scope
- config/quickshell/core/Config.qml — declare `colours.sourceColorIndex` + change handler.
- config/quickshell/services/Wallpaper.qml — source-colors query service.
- config/quickshell/features/settings/content/ThemingPage.qml — swatch row UI.
- odd/tasks/matugen-show-source-colors.md (this file).

Out of scope: matugen templates/config.toml, other settings pages, Nix mirror.

## Tasks
- [x] T1 Config.qml: declare `property int sourceColorIndex: 0` inside `colours`
      JsonObject and add `onSourceColorIndexChanged: Wallpaper.changeColourProp();`
      (same pattern as `onGenTypeChanged`). — DONE by agy (Config.qml +4).
- [x] T2 Wallpaper.qml: add `sourceColors` (list of up to 5 hex strings, ordered
      by dominance), `sourceColorsLoading`, `refreshSourceColors()` and a
      `sourceColorsProc` Process with StdioCollector running
      `matugen image <cleanPath> --show-source-colors`; parse lines matching
      `^#[0-9A-Fa-f]{6}$` (max 5); refresh automatically when
      `Config.settings.currentWallpaper` changes. — DONE by agy (Wallpaper.qml
      +58; Connections on Config.settings.onCurrentWallpaperChanged; saved index
      clamped to 0 when it exceeds the candidate count).
- [x] T3 ThemingPage.qml: replace the "Matugen source color index"
      GenericNumberOption with a swatch row (same layout as generic options):
      swatches per candidate color, highlight active index with
      `Colours.palette.primary`, click -> `Config.updateKey("colours.sourceColorIndex", idx)`
      + defensive `Wallpaper.changeColourProp()`; placeholder while loading/empty
      ("progress_activity" icon), manual refresh button ("refresh" icon).
      Hidden when useCustom is on. — DONE by agy (ThemingPage.qml +149/-17).
- [x] T4 Verify (orchestrator): `qmllint` on the three files exit 0 (agent ran it
      too, reported 0 errors; spot-check re-run by orchestrator: exit 0).
      Live deploy + `qs log` check pending user action (shell restart not forced
      from orchestrator). Commit: this work-unit commit on
      `feat/quickshell-matugen-source-colors`.
      Deferred: `./scripts/sync-quickshell.sh` deploy + `qs log -t 30` by the
      user (or a later session) to avoid disturbing the live shell mid-session.

## Route and delivery
- Route: delegated direct — writer is the external agent `agy` (user-ordered),
  orchestrated through Herdr (`herdr agent prompt agy ... --wait`).
  Mapping trigger fired first (ThemingPage.qml, Wallpaper.qml, Config.qml,
  matugen CLI, settings.json, sync script = 6 sources read for understanding)
  and was completed by the orchestrator before delegating.
- Authorization: explicit change request ("dile a agy que la implemente").
  Scope limited to the three QML files plus this task document.
- TDD: off — dotfiles project, no test runner (source: AGENTS.md "No Test Suite").
  Functional checks: qmllint + live reload log + matugen CLI sanity.
- Delivery strategy: `ask-on-risk` (default). Forecast ≈ 150-180 authored lines
  (< 400) and no chained-PR recommendation -> single work-unit commit on a
  feature branch (we were on `main`; branch created before first write).
- RDD: on (decided by default). Native review candidate = the work-unit commit;
  assess with `--base-ref main --committed-only` after the commit exists.

## Acceptance criteria
- ThemingPage shows swatches of the candidate source colors of the current
  wallpaper; clicking a swatch updates `colours.sourceColorIndex` persistently
  and regenerates the scheme from that index.
- The wallpaper change refreshes the swatches without QML errors.
- The old non-operative numeric selector is gone, replaced by the swatch row.
- qmllint reports no NEW errors vs base on the edited files.

## Progress log
- [x] Plan verified and delegated to `agy` (via herdr, agent idle w1:p5).
- [x] T1-T3 implemented by `agy` (Antigravity CLI / Gemini 3.8 Flash); reported
      "DONE" with +194/-17 across the three files; qmllint 0 errors.
- [x] Orchestrator spot-check: structural readback of all three files + qmllint
      re-run (exit 0). Router-decision risk: none found.
- [x] Work-unit commit created on the feature branch (see git log for hash).
