# ROADMAP.md
**Purpose:** Permanent reference for project context, current state, and phased plan. Read this before making structural changes or starting a new session — it should be kept in sync with actual repo state, not aspirational state.
 
---
 
## 1. Project Overview
 
**Concept:** Roblox PvE RTS, StarCraft 2-style — top-down scriptable camera, drag-box unit selection, right-click move commands, base-building/economy leading into wave-based PvE combat.
 
**Tech Stack:**
- Luau, `--!strict` on all modules
- Roblox client/server model: `LocalScript`s in `StarterPlayerScripts`, server logic in `ServerScriptService`, shared code/data in `ReplicatedStorage`
- No third-party frameworks currently in use (no Knit/Rodux/etc.) — plain service-table pattern (`Service.start()`) and `require`-based modules
**Sync Architecture:**
- Repo uses a script-sync workflow with the active Roblox Studio environment (Roblox Studio built-in Script Sync, confirmed by the user).
- Directory paths in this repo mirror the actual Studio instance tree (e.g. `ServerScriptService/Services/UnitFactory.luau` → `game.ServerScriptService.Services.UnitFactory`).
- **Do not restructure directories without confirming the sync mapping** — moving a file changes where it lands in the DataModel. If ambiguous, ask before writing code or renaming/moving files.
---
 
## 2. Current State
 
### Implemented in code (Studio runtime verification pending)
- Scriptable RTS camera, hidden proxy character, and CoreGui suppression.
- `SelectionUtils` projects unit roots into a drag rectangle. Selection tracks multiple units and creates local highlights.
- `UnitFactory` creates Swordsman/Archer models with `OwnerUserId`; health is initialized from stats and physics ownership is assigned to the server. Server-side `Humanoid.HealthChanged` deletes the model at zero health. The model `Health` attribute remains static spawn configuration; `Humanoid.Health` is the live value.
- `MoveUnit` accepts a unit array. Server validation checks a bounded dense array, finite destination, direct `workspace.Units` membership, known unit type, ownership, root, and live Humanoid. Duplicate units are ignored.
- `SpawnUnit` creates owned units through the centrally started `UnitSpawnService`; keys 1/2 request Swordsman/Archer. This is a temporary trigger for the prototype.
- Movement/spawn requests have per-player cooldowns (0.1s / 0.25s); movement accepts at most 200 array entries.
- Selection filters owned/live units, prunes stale references before movement and when selected models leave `workspace.Units`, handles focus loss, and offsets the drag display for GUI insets.
- The legacy `UnitFactoryTest.legacy.luau` script has been removed.

### Missing / deferred
- No economy, resource HUD, or spawn cost gate (Phase 3).
- No combat, enemy waves, or win/lose condition (Phases 4–5).
- Spawn positions remain a prototype offset derived from UserId; repeated spawns share a position and UserId offsets can collide.
- Debug output remains ungated (Phase 6).
- GUI/remotes/Units are Studio-authored; no sync configuration or place file is in this checkout.

### Current goalpost — Phase 2 completion and verification
Baseline reviewed: `main` at `6f316d9081d3ee24d48963f49febab12c1c5a0db`.
Implementation branch: `fix/phase-2-validation`.
Phase 1 and 2 functionality exists in code. Complete their validation and Studio acceptance checks before starting Phase 3. Checked roadmap items below mean implemented, not runtime-tested.

**Acceptance criteria (pending Studio verification):**
1. In a two-player Studio session, keys 1/2 spawn the correct owned unit type. Each client selects/highlights only its own live units, by click or drag in all four directions.
2. Right-click moves selected owned/live units. Direct foreign-unit requests do not move the foreign unit. A mixed array moves only valid owned units; duplicates issue one command.
3. Nil/non-table/sparse/dictionary/over-200 movement payloads, non-Vector3 or NaN/infinite destinations, non-model instances, units outside `workspace.Units`, unknown unit types, dead units, and destroyed references produce no invalid movement or server errors.
4. Requests inside the cooldown do no extra work; a valid request after the cooldown succeeds. Invalid spawn types are rejected. Leaving a session clears limiter state.
5. The drag frame tracks the cursor with `RtsGui.IgnoreGuiInset` both true and false. GUI-consumed clicks do not select on mouse-up; losing window focus cancels the drag.
6. In the server Explorer, set `Workspace.Units.<unit>.Humanoid.Health` to zero (not the model Health attribute). The model and its highlight must disappear on both clients, including during an existing movement command. Remaining selected units must continue to accept movement without errors. Confirm unit health matches config and server network ownership remains in effect. Confirm actual locomotion on the current Studio-authored ground; a `MoveTo` call alone does not establish that the prototype rig can walk.

**Manual Studio requirements (verify existing instances; no new instances required):**
- `Workspace.Units` — Folder.
- `ReplicatedStorage.Remotes.MoveUnit` and `.SpawnUnit` — RemoteEvents.
- `StarterGui.RtsGui` — ScreenGui, with direct child `SelectionBox` — Frame. Keep it free of layout/size constraints that override drag positioning; the client sets AnchorPoint to zero and initializes Visible=false.
- Existing script paths map directly to the named services; repository `StarterPlayerScripts` corresponds to Studio `StarterPlayer.StarterPlayerScripts`.

**Verification status:** All 13 repository Luau scripts compiled with the upstream Luau compiler (syntax only; no Roblox-aware type analysis). A temporary harness executed the actual movement/spawn service sources against mocked services: 22 assertions passed for valid requests, foreign ownership, duplicate/mixed arrays, malformed/sparse/oversize payloads, nonfinite destinations, missing/dead/destroyed units, cooldowns, independent player state, cleanup, and idempotent start. `git diff --check` passed. These local checks do not establish Roblox physics or GUI behavior.

**User-reported Studio results:** The initial walkthrough passed except the zero-health test: the user reported units could still move after setting health to zero in the server environment. The exact edited health field and cause have not been confirmed. Targeted payload/cooldown checks beyond the walkthrough remain pending. Added server deletion at zero `Humanoid.Health` and client selection pruning on removal. Both changed scripts compiled; 12 mocked lifecycle assertions passed for healthy/nonlethal units, lethal deletion, static-vs-live health, highlight cleanup, surviving selection, repeated cleanup, and external removal. Studio retest is pending. No Studio tests have been run by the assistant.

---
 
## 3. Phased Roadmap
 
### Phase 0 — Cleanup (prerequisite for new feature work)
- [x] Delete/retire `UnitFactoryTest.legacy.luau` once a real spawn trigger exists (Phase 2).
- [x] Ownership model established in code: per-player `OwnerUserId`; neutral/enemy ownership remains deferred until its relevant phase.
### Phase 1 — Core Multi-Selection Loop
- [x] Implement `SelectionUtils.raycastUnitsInScreenRect(topLeft, bottomRight)`: iterate `workspace.Units`, project each unit's `HumanoidRootPart` via `Camera:WorldToViewportPoint`, test against the drag rect.
- [x] Extend `RtsSelectionController` to track `selectedUnits: {Model}` (not a single `Model?`), wire drag-release into the new util.
- [x] Add selection visual feedback through client-created highlights.
- [x] Update `MoveUnit` remote signature to accept an array of units; server validates each is a real, live unit under `workspace.Units` before acting.
### Phase 2 — Server-Authoritative Unit Ownership
- [x] Add numeric `OwnerUserId` at spawn time in `UnitFactory` (attributes cannot store Player instances).
- [x] Restrict `UnitMovementService`'s `MoveUnit.OnServerEvent` to only act on units owned by the firing player.
- [x] Add a `SpawnUnit` remote + server handler so unit creation is player-triggered, not hardcoded in a legacy script.
### Phase 3 — Basic Economy
- [ ] Add `ResourceService` (server) tracking currency per player.
- [ ] Gate `SpawnUnit` requests against `UnitData[type].Cost`; reject/refund on insufficient funds.
- [ ] Add minimal resource HUD (client) reflecting balance via RemoteEvent or player Attribute.
### Phase 4 — Combat
- [ ] Add `Damage` and `AttackSpeed` fields to `UnitStats` in `UnitData.luau` (currently absent).
- [ ] Add a runtime "current health" attribute distinct from the static config `Health` value.
- [ ] Server-side combat loop: units acquire nearest valid enemy in `AttackRange`, deal damage on an interval, die and clean up at 0 HP.
- [ ] Team/faction check to prevent friendly fire — depends on Phase 2 ownership data.
### Phase 5 — Enemy AI / Wave Spawner
- [ ] `EnemyWaveService`: timed spawns of hostile units at a defined spawn point.
- [ ] Enemy pathing toward player base (`Humanoid:MoveTo` waypoints or `PathfindingService`).
- [ ] Win/lose condition tied to a base structure's HP.
### Phase 6 — Polish & Scale
- [ ] Object pooling for units — currently every unit is a fresh `Instance.new` tree; needed once wave counts grow.
- [ ] Evaluate replacing per-unit `Humanoid` with a lighter movement scheme (Humanoids are expensive at RTS-scale unit counts; worth prototyping before 50+ units on screen is a normal state).
- [ ] Gate `RtsDebugLogger` output behind a dev-only flag before any external playtest.
---
 
## 4. Technical Constraints & Guidelines
 
**Architecture rules:**
- All new modules use `--!strict`.
- Server logic never trusts client-supplied Instance references without validating existence, type, and ownership.
- Shared config (unit stats, costs, etc.) lives in `ReplicatedStorage/Configs`, is `table.freeze`'d, and is validated at module load (see `UnitData.luau` pattern — replicate this for any new data tables).
- Services follow the `Service.start()` table-module pattern; wire-up happens centrally in `RtsServerInit.server.luau` (server) — no service should self-start on `require`.
- Remotes live under `ReplicatedStorage.Remotes`, fetched via `WaitForChild`, typed with `:: RemoteEvent` / `:: RemoteFunction`.
**Directory norms (mirrors Studio instance tree via sync):**
```
ReplicatedStorage/
  Configs/      -- frozen, validated static data tables
  Modules/      -- shared pure-logic utilities (client+server safe)
  Remotes/      -- RemoteEvents/RemoteFunctions (Studio-authored instances)
ServerScriptService/
  Services/     -- server-only service modules (Service.start() pattern)
  RtsServerInit.server.luau  -- single entry point, requires + starts services
StarterPlayerScripts/
  *.local.luau  -- client-only scripts, run independently (no central init except RtsGameInitializer for CoreGui)
```
 
**Sync considerations:**
- File path = DataModel path. Do not rename/move files without confirming the intended Studio location first.
- UI instances (e.g. `RtsGui`, `SelectionBox`) may be Studio-authored and not represented as files — check before assuming a GUI element needs to be scripted from scratch.
- When ambiguity exists about where a new file/instance should live in the sync tree, ask before writing code.
**Known technical debt to track:**
- Phase 1/2 runtime acceptance checks remain pending.
- `AttackRange` and `Cost` attributes exist on units but are currently inert.
- Hotkey spawning and UserId-based spawn offsets remain prototype paths until their relevant replacement goalposts.
