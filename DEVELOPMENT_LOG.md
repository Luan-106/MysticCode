# Development Log — GLITCH//SHIFT: DON'T LOOK BACK
**MysticCode | Unreal Engine 5.8 | 24-Hour Game Jam**

---

## Phase 0: Project Inspection & Critical Fixes — ✅ COMPLETE
**Timestamp:** 2026-10-23

### Repository Discovery
Found multiple project locations:
- `C:\Users\Harsh\MysticCode` — GitHub-linked repo (`main` branch → https://github.com/Luan-106/MysticCode), contains only docs/gitignore
- `C:\Users\Harsh\OneDrive\Documents\Unreal Projects\MysticCode` — **Main working project** (UE 5.8, `master` branch, local only)  
- `C:\Users\Harsh\OneDrive\Documents\Unreal Projects\MysticCode 5.8` — Backup/alternate version
- `C:\Users\Harsh\source\repos\MysticCode` — Another local copy

**Engine confirmed:** Unreal Engine 5.8 at `C:\Program Files\Epic Games\UE_5.8`  
**Project type:** Blueprint-only (no C++ Source/ directory)  
**Existing state:** Documentation comprehensive, but `.upl` stub files ≠ real `.uasset` Blueprints

### Critical Bugs Fixed

| Bug | Impact | Fix |
|-----|--------|-----|
| `.uproject` had malformed internal UE JSON | Project wouldn't open properly | Fixed to proper `EngineAssociation: "5.8"` format |
| `.gitignore` excluded `*.uasset` | ALL Blueprint assets would be lost from git! | Rewrote gitignore — only excludes Binaries/Intermediate/Saved/DerivedDataCache |
| `DefaultInput.ini` missing all gameplay keybindings | No player input at runtime | Added WASD, Sprint, Interact, Flashlight, RealityShift, Jump, Crouch, Escape |
| `DefaultGame.ini` missing | No default game mode or maps configured | Created with BP_GameMode and FacilityMap settings |

### Files Created/Modified
```
Modified:  MysticCode.uproject         (fixed JSON format, added EnhancedInput plugin)
Modified:  .gitignore                  (critical fix: no longer excludes .uasset)
Modified:  Config/DefaultInput.ini     (all gameplay keybindings added)
Created:   Config/DefaultGame.ini      (game mode + map defaults)
Created:   Scripts/auto_setup.py       (UE Python script: auto-creates all Blueprint stubs)
Modified:  MANUAL_SETUP.md             (complete 19-step implementation guide)
Modified:  README.md                   (accurate status and controls)
Modified:  TEST_CHECKLIST.md           (full P0/P1/P2 test matrix)
Modified:  DEVELOPMENT_LOG.md          (this file)
```

### Git Status (Working Project)
- Branch: `master` (local only, no remote configured)
- Clean tree after all edits committed
- Previous commits: 5 (project setup, launcher, engine update, docs)

### GitHub Repo (C:\Users\Harsh\MysticCode)
- Branch: `main` → `origin/main` (https://github.com/Luan-106/MysticCode)
- Fixed: `.gitignore` (was Node.js boilerplate, now UE5-correct)
- Fixed: `README.md` (full game info, controls, build status)
- Pending commit: 2 changed files (gitignore + README)

---

## Phase 1: Blueprint Implementation — ⏳ PENDING (Requires Unreal Editor)

**What requires manual editor work (see MANUAL_SETUP.md):**

### Core Systems
- [ ] Run `Scripts/auto_setup.py` → Creates BP stubs + folder structure
- [ ] BP_PlayerCharacter: camera, WASD, sprint/stamina, flashlight, reality shift, interaction trace
- [ ] BPI_Interactable: interface functions (Interact, GetInteractionText, CanInteract)
- [ ] BP_GameMode: default pawn, HUD creation on BeginPlay

### Interactables  
- [ ] BP_Door: open/close timeline, locked state, keycard check
- [ ] BP_Keycard: pickup, bitmask inventory addition
- [ ] BP_PowerRelay: activation, light change, notify ObjectiveManager
- [ ] BP_Keypad: opens WBP_KeypadInput, code validation, linked door unlock
- [ ] BP_Note: shows text widget on interact
- [ ] BP_ExitElevator: triggers victory screen + level reload

### Systems
- [ ] BP_ObjectiveManager: relay count tracking, objective text updates
- [ ] BP_RealityManager: paired actor visibility/collision toggle, post-process change
- [ ] BP_Subject0: state machine AI (Patrol → Investigate → Chase → Attack → Search)
- [ ] BP_Subject0_AIController: basic controller delegation

### UI Widgets
- [ ] WBP_MainMenu: title, Start Game, Quit
- [ ] WBP_GameHUD: objective, relay progress, keycard, reality state, interaction prompt, stamina
- [ ] WBP_PauseMenu: Resume, Restart, Main Menu, Quit
- [ ] WBP_DeathScreen: captured text, restart/menu buttons
- [ ] WBP_VictoryScreen: escaped text, play again/menu buttons
- [ ] WBP_KeypadInput: digit display, 0-9 buttons, Enter, Delete, Cancel

### Input
- [ ] IMC_MysticCode: bind all IA_ assets to correct keys
- [ ] Enhanced Input Mapping Context wired in BP_PlayerCharacter BeginPlay

---

## Phase 2: Level Design — ⏳ PENDING

### FacilityMap Layout Target
```
[PlayerStart] → Containment Cell (Area 1: Tutorial)
     ↓
Corridor + BP_Door (unlocked)
     ↓  
Wrong Floor Room (Area 2: Reality Shift Puzzle)
  Normal: north door locked, west blocked
  Corrupted: west passage opens → Relay 1 accessible
BP_Keycard (blue) somewhere here
     ↓
Subject 0 Corridors (Area 3: Power Restoration)
  Relay 2 (alcove)
  Relay 3 (server room)  
  BP_Subject0 + 4x BP_PatrolPoint
  Exit door unlocks when all 3 relays active
     ↓
Don't Look Back Corridor (Area 4: Final Escape)
  Code hint: "0452" written on wall mid-corridor
  BP_Keypad at end (code: 0452) → opens final door
  BP_ExitElevator at very end
  Research Log 04 at entrance
```

### NavMesh
- Place Nav Mesh Bounds Volume covering entire playable area
- Build Navigation (Build → Build Navigation)
- Test Subject 0 movement paths

---

## Phase 3: Integration & Testing — ⏳ PENDING

### Session goal: Everything connected and testable
- All Blueprint references valid (no null refs)
- ObjectiveManager receives relay events
- RealityManager's actor arrays populated in level
- Subject 0 has patrol points assigned
- All doors have LinkedDoor/RequiredKeycard set
- HUD connected to player and objective manager
- Death → restart → HUD reset works

---

## Current Known Blockers

1. **Unreal Editor required for Blueprints** — Cannot create `.uasset` files via script alone  
2. **No audio assets** — Game runs silently; document in TEST_CHECKLIST.md  
3. **No character/enemy mesh** — Subject 0 uses Unreal Mannequin placeholder  
4. **GitHub and working project are separate repos** — Need to sync after editor work

---

## Commit History (Working Project)

| Hash | Message |
|------|---------|
| 91217d3 | docs: update development log with phase completion status |
| 651ed08 | docs: update development log with phase tracking |
| fe19fc5 | feat: update engine version to 5.8 to match installed UE version |
| d460dbf | chore: add launcher batch files and update project tracking |
| d8cf3b3 | feat: initial project setup with documentation and project configuration |

---

## Next Three Tasks (Priority Order)
1. **Open UE 5.8 → Run `Scripts/auto_setup.py`** → Creates all Blueprint stubs
2. **Follow MANUAL_SETUP.md Steps 1-10** → Implement player + core systems in editor  
3. **Build FacilityMap level layout** → Blockout geometry, place actors, build NavMesh