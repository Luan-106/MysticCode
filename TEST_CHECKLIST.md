# Test Checklist — GLITCH//SHIFT: DON'T LOOK BACK

## Status Legend
- ✅ PASS — Tested and working
- ❌ FAIL — Tested, broken (see notes)  
- ⚠️ UNVERIFIED — Not yet tested
- 🔒 BLOCKED — Cannot test (missing dependency / requires editor)

---

## P0 — Core (Must Work)

| # | Test | Status | Notes |
|---|------|--------|-------|
| P0-01 | Project opens in UE 5.8 without errors | ⚠️ UNVERIFIED | .uproject format fixed |
| P0-02 | Player can move (WASD) | ⚠️ UNVERIFIED | Requires BP_PlayerCharacter setup in editor |
| P0-03 | Player can look around (Mouse) | ⚠️ UNVERIFIED | Requires BP_PlayerCharacter setup |
| P0-04 | Sprint works (Left Shift) | ⚠️ UNVERIFIED | Requires BP_PlayerCharacter setup |
| P0-05 | Interaction prompt appears when facing interactable | ⚠️ UNVERIFIED | Requires BPI_Interactable + HUD |
| P0-06 | E key triggers interaction correctly | ⚠️ UNVERIFIED | Requires TryInteract function |
| P0-07 | Doors open and close | ⚠️ UNVERIFIED | Requires BP_Door + level placement |
| P0-08 | Locked door blocks without keycard | ⚠️ UNVERIFIED | Requires BP_Door locked logic |
| P0-09 | Locked door opens WITH correct keycard | ⚠️ UNVERIFIED | Requires BP_Keycard + inventory |
| P0-10 | Flashlight toggles on F key | ⚠️ UNVERIFIED | Requires SpotLight component |
| P0-11 | Reality Shift toggles on Q key | ⚠️ UNVERIFIED | Requires BP_RealityManager |
| P0-12 | Reality Shift doesn't trap player in geometry | ⚠️ UNVERIFIED | Requires level layout |
| P0-13 | At least one puzzle works (power relays) | ⚠️ UNVERIFIED | Requires 3x BP_PowerRelay |
| P0-14 | Final exit can be reached and triggered | ⚠️ UNVERIFIED | Requires level + exit actor |
| P0-15 | Death/capture triggers death screen | ⚠️ UNVERIFIED | Requires Subject 0 + WBP_DeathScreen |
| P0-16 | Restart after death reloads level correctly | ⚠️ UNVERIFIED | Requires restart button logic |
| P0-17 | Git repo has no large generated files (>100MB) | ⚠️ UNVERIFIED | .gitignore fixed, needs verification |

## P1 — Strongly Desired

| # | Test | Status | Notes |
|---|------|--------|-------|
| P1-01 | Both puzzles work (relays + keypad) | ⚠️ UNVERIFIED | Needs keypad widget wiring |
| P1-02 | Keycard + locked door system end-to-end | ⚠️ UNVERIFIED | |
| P1-03 | Enemy patrols between points | ⚠️ UNVERIFIED | Requires NavMesh + patrol points |
| P1-04 | Enemy detects and chases player | ⚠️ UNVERIFIED | Requires CanSeePlayer logic |
| P1-05 | Enemy attack triggers death sequence | ⚠️ UNVERIFIED | Requires AttackRange check |
| P1-06 | HUD shows: objective, relay progress, reality state | ⚠️ UNVERIFIED | Requires WBP_GameHUD |
| P1-07 | Pause menu works: Resume / Restart / Quit | ⚠️ UNVERIFIED | Requires WBP_PauseMenu |
| P1-08 | Story notes are readable | ⚠️ UNVERIFIED | Requires BP_Note + widget |
| P1-09 | Sprint stamina drains and recovers | ⚠️ UNVERIFIED | Requires Tick logic |
| P1-10 | Victory screen shows when exit triggered | ⚠️ UNVERIFIED | Requires BP_ExitElevator |

## P2 — Nice to Have

| # | Test | Status | Notes |
|---|------|--------|-------|
| P2-01 | Ambient audio plays | 🔒 BLOCKED | No audio assets available |
| P2-02 | Footstep sounds on movement | 🔒 BLOCKED | No audio assets |
| P2-03 | Reality shift audio effect | 🔒 BLOCKED | No audio assets |
| P2-04 | Enemy proximity heartbeat audio | 🔒 BLOCKED | No audio assets |
| P2-05 | Post-process glitch effect in corrupted reality | ⚠️ UNVERIFIED | Requires post-process material |
| P2-06 | Don't Look Back sequence (lights fail, enemy spawns) | ⚠️ UNVERIFIED | Requires Level Blueprint triggers |
| P2-07 | Enemy search behavior | ⚠️ UNVERIFIED | |
| P2-08 | Packaged Windows .exe runs | ⚠️ UNVERIFIED | Try after core features work |

---

## Critical Bugs Found & Fixed

| Bug | Severity | Fix Applied |
|-----|----------|-------------|
| `.uproject` had malformed internal UE JSON format | Critical | ✅ Fixed — proper plugin list + EngineAssociation: "5.8" |
| `.gitignore` excluded `*.uasset` — would lose all Blueprints! | Critical | ✅ Fixed — rewrote gitignore |
| `DefaultInput.ini` missing WASD/interact/flashlight/shift bindings | High | ✅ Fixed — added all legacy mappings |
| `DefaultGame.ini` did not exist — no game mode/map configured | High | ✅ Created |
| Content/*.upl files are not real Unreal assets | Medium | ℹ️ Must be replaced by creating real assets in editor |
| Previous huge file (>100MB) blocked push | High | ℹ️ .gitignore now excludes Intermediate/ |

---

## Pre-Commit Safety Checklist

Before each git push:
- [ ] `git status` shows no Intermediate/, Saved/, or DerivedDataCache/ files
- [ ] No single file exceeds 100MB (`git ls-files --others | Get-Item | Where Size -gt 100MB`)
- [ ] `.uasset` files ARE tracked (not excluded)
- [ ] Config/ directory IS tracked
- [ ] Content/ directory IS tracked
- [ ] Commit message is descriptive

---

## Test Environment

- **OS:** Windows 11
- **Engine:** Unreal Engine 5.8
- **Testing Method:** Play-in-Editor (PIE)
- **Target Platform:** Windows 64-bit