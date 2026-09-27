# Feature: Settings sidebar collapse persistence

## Objective
Persist the settings window sidebar collapse state (`true`/`false`) so that
reopening the SettingsWindow (and restarting the shell) restores the last state.

## Problem / Why
- `features/settings/SettingsSidebar.qml:19` declares
  `property bool collapsed: false` as a plain local property.
- `SettingsWindow.qml` wraps everything in a `Loader` whose `active` goes false
  250ms after close, destroying the component tree. On reopen the sidebar is
  recreated with `collapsed: false`.

## Evidence
- `SettingsWindow.qml:214` consumes `sidebar.collapsed` for preferred width.
- `SettingsSidebar.qml:73` toggles with direct assignment `root.collapsed = !root.collapsed`.
- `SettingsControl.qml` is a `pragma Singleton` (survives window reload, not
  shell restart) but the repo's real persistence layer is Config/JsonAdapter.

## Scope
- `config/quickshell/core/Config.qml` — declare the persisted key.
- `config/quickshell/features/settings/SettingsSidebar.qml` — reactive binding + toggle via updateKey.
Out of scope: `settingsLocation` persistence, sidebar layout redesign.

## Tasks
- [x] T1 Config.qml: inside `misc` JsonObject add
      `property bool settingsSidebarCollapsed: false`. — DONE by agy.
- [x] T2 SettingsSidebar.qml: replace line 19 with
      `readonly property bool collapsed: Config.settings.misc.settingsSidebarCollapsed`
      and change the collapse button onClicked to
      `Config.updateKey("misc.settingsSidebarCollapsed", !root.collapsed)`.
      Keep all internal `root.collapsed` consumers unchanged. — DONE by agy
      (+3/-2 total; qmllint OK, orchestrator spot-check re-run).

## Route and delivery
- Route: delegated direct — writer is external agent `agy` via herdr
  (user-ordered, same topology as previous feature). Exploration (4 files:
  SettingsWindow, SettingsSidebar, SettingsControl, Config) done by orchestrator.
- Authorization: explicit change request ("dile a agy que la implemente").
- TDD: off — dotfiles, no test runner. Checks: qmllint + live reload log.
- Delivery: `ask-on-risk` default; forecast ~15 authored lines (<400) ->
  single work-unit commit on `feat/quickshell-matugen-source-colors` (same
  feature branch, boundary still unreviewed/under budget).

## Acceptance criteria
- Collapse sidebar -> close window -> reopen: sidebar still collapsed.
- Expand -> reopen: sidebar expanded.
- State survives a full quickshell restart (persisted in settings.json).
- qmllint exit 0 on both edited files; no QML errors on live reload.

## Progress log
- [x] Plan complete; delegated to `agy` (herdr w1:p5).
- [x] T1-T2 implemented by agy: +3/-2 across Config.qml + SettingsSidebar.qml;
      qmllint exit 0 (agent + orchestrator spot-check).
- [x] Work-unit commit on the feature branch (see git log).
- [x] Live deploy via scripts/sync-quickshell.sh; quickshell reload clean.
- [ ] User acceptance: collapse -> close -> reopen keeps state.
