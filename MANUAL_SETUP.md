# MANUAL SETUP GUIDE — GLITCH//SHIFT: DON'T LOOK BACK

> **THIS IS THE CRITICAL DOCUMENT.** Since Blueprints cannot be created fully by script alone, follow these exact steps in the Unreal Editor to build the complete game.

## Prerequisites

- Unreal Engine 5.8 installed at `C:\Program Files\Epic Games\UE_5.8`
- Project location: `C:\Users\Harsh\OneDrive\Documents\Unreal Projects\MysticCode`
- Launch editor via: `LaunchEditor.bat` or directly from UE Launcher

---

## STEP 0: Run the Auto-Setup Script

1. Open Unreal Engine 5.8 and load `MysticCode.uproject`
2. In the Editor: **Tools → Execute Python Script...**
3. Navigate to and select: `Scripts/auto_setup.py`
4. Click **Open** — the script will create all Blueprint stubs and folder structure
5. Check the Output Log for any errors

> If the Python script fails, create the following folders manually in Content Browser:
> `/Game/Blueprints/Core`, `/Game/Blueprints/Interactables`, `/Game/Blueprints/AI`, `/Game/Blueprints/UI`, `/Game/Input`, `/Game/Maps`

---

## STEP 1: Game Mode Setup

### BP_GameMode
1. Open `Content/Blueprints/Core/BP_GameMode`
2. In Class Defaults:
   - **Default Pawn Class**: `BP_PlayerCharacter`
   - **Player Controller Class**: `BP_PlayerController`
   - **HUD Class**: None (we use Widget-based HUD)
3. Add **Event BeginPlay**:
   - Create Widget: `WBP_GameHUD`, Add to Viewport
   - Set `bShowMouseCursor` = False
   - Set Input Mode: Game Only
4. Save the Blueprint

### Project Settings → Maps & Modes
1. Go to **Edit → Project Settings → Maps & Modes**
2. **Default GameMode**: `BP_GameMode`
3. **Editor Startup Map**: `FacilityMap`
4. **Game Default Map**: `FacilityMap`

---

## STEP 2: Player Character — BP_PlayerCharacter

1. Open `Content/Blueprints/Core/BP_PlayerCharacter`
2. In the **Components panel**, add:
   - **Camera** component: name it `FP_Camera`
     - Set location: X=0, Y=0, Z=60 (head height)
     - Enable: `bUsePawnControlRotation = True`
   - **SpotLight** component: name it `Flashlight`
     - Attach to `FP_Camera`
     - Set location: X=10, Y=0, Z=-5
     - Intensity: 5000, Attenuation Radius: 2500
     - Inner Cone Angle: 15, Outer Cone Angle: 30
     - **Visible = False** (starts off)
   - **Spring Arm** (optional, not needed for FPS — delete if added)

3. In **Class Defaults**:
   - **Auto Possess Player**: Player 0
   - **Use Controller Rotation Yaw**: True
   - **Use Controller Rotation Pitch**: False
   - **Use Controller Rotation Roll**: False

4. In the **CharacterMovement** component:
   - **Max Walk Speed**: 400
   - **Max Sprint Speed** (custom var): 700
   - **Jump Z Velocity**: 420
   - **Gravity Scale**: 1.0
   - **bOrientRotationToMovement**: False

5. **Variables to add** (in My Blueprint panel):
   ```
   bIsFlashlightOn     Boolean  = false
   bIsInCorruptedReality Boolean = false
   bIsSprinting        Boolean  = false
   bIsDead             Boolean  = false
   InteractionRange    Float    = 350.0
   SprintSpeed         Float    = 700.0
   WalkSpeed           Float    = 400.0
   Stamina             Float    = 100.0
   MaxStamina          Float    = 100.0
   CurrentKeycard      Integer  = 0  (bitmask: 1=red,2=blue,4=green)
   CurrentObjective    String   = "Find a way out of this room"
   RealityManager      Object Reference → BP_RealityManager
   HUDWidget           Object Reference → WBP_GameHUD
   ```

6. **Input Setup (Enhanced Input)**:
   - In **BeginPlay**:
     - Get Player Controller → Cast to BP_PlayerController
     - Add Mapping Context: `IMC_MysticCode` (Priority 0)
   - **IA_Move** (Axis2D): 
     - Add Movement Input: Forward Vector * Y, Right Vector * X
   - **IA_Look** (Axis2D):
     - Add Controller Yaw Input * X
     - Add Controller Pitch Input * Y  
   - **IA_Sprint** (Started): Set `bIsSprinting` = True, Max Walk Speed = 700
   - **IA_Sprint** (Completed): Set `bIsSprinting` = False, Max Walk Speed = 400
   - **IA_Jump** (Started): Call Jump function
   - **IA_Interact** (Started): Call `TryInteract` function (see below)
   - **IA_Flashlight** (Started): Call `ToggleFlashlight` function
   - **IA_RealityShift** (Started): Call `TriggerRealityShift` function
   - **IA_Menu** (Started): Call `TogglePauseMenu` function

7. **Custom Functions**:

   **TryInteract**:
   ```
   LineTraceByChannel from FP_Camera location to FP_Camera forward * InteractionRange
   Channel: Visibility
   If Hit:
     Get Hit Actor → Does Implement Interface (BPI_Interactable)?
     If Yes: Call BPI_Interactable::Interact(self)
   ```

   **ToggleFlashlight**:
   ```
   bIsFlashlightOn = NOT bIsFlashlightOn
   Set Flashlight.Visible = bIsFlashlightOn
   ```

   **TriggerRealityShift**:
   ```
   Get BP_RealityManager (by tag or reference)
   Call ShiftReality() on it
   Play camera shake / post-process effect
   ```

   **TogglePauseMenu**:
   ```
   If game is paused:
     Unpause, Remove Pause Widget, Set Input Mode Game Only
   Else:
     Pause, Create WBP_PauseMenu, Add to Viewport, Set Input Mode UI Only
   ```

   **PlayerDied** (call when killed by Subject 0):
   ```
   bIsDead = True
   Stop movement: Set Max Walk Speed = 0
   Play death sound (if available)
   Create WBP_DeathScreen, Add to Viewport
   Set Input Mode UI Only, Show Mouse Cursor
   ```

   **RestartGame**:
   ```
   Open Level (current level name) → reloads everything
   ```

8. In the **Tick** event:
   - If `bIsSprinting` AND Velocity.Size > 50: Drain Stamina (Rate: 20/sec)
   - Else if NOT sprinting: Recover Stamina (Rate: 10/sec)
   - Clamp Stamina 0-MaxStamina
   - If Stamina <= 0: Set bIsSprinting = False, Max Walk Speed = WalkSpeed
   - Interaction Trace (called via Tick or directly):
     - LineTrace for interactable in front
     - Update `WBP_GameHUD` → Show/Hide interaction prompt

---

## STEP 3: BPI_Interactable Interface

1. Open `Content/Blueprints/Core/BPI_Interactable`
2. Add these **Interface Functions**:
   - `Interact(PlayerRef: BP_PlayerCharacter)` — called when player presses E
   - `GetInteractionText()` returns String — e.g., "Press E to Open Door"
   - `CanInteract(PlayerRef: BP_PlayerCharacter)` returns Boolean
3. Save

---

## STEP 4: Doors — BP_Door

1. Open `Content/Blueprints/Interactables/BP_Door`
2. **Implement Interface**: BPI_Interactable
3. **Components**:
   - Static Mesh (Door Frame): `SM_DoorFrame` or a cube (200x20x200)
   - Static Mesh (Door Panel): `SM_Door` or a cube (190x10x190), named `DoorMesh`
   - Box Collision: trigger for interaction range
4. **Variables**:
   ```
   bIsOpen         Boolean = false
   bIsLocked       Boolean = false
   RequiredKeycard Integer = 0   (0=none, 1=red, 2=blue, 4=green)
   bNormalRealityOnly Boolean = false
   bCorruptedRealityOnly Boolean = false
   InteractionText String = "Press E to Open Door"
   ```
5. **Interact function**:
   ```
   If bIsLocked:
     Check if Player.CurrentKeycard has RequiredKeycard bit set
     If yes: Set bIsLocked = false, Open Door
     If no: Play locked sound, Show "LOCKED - Need Keycard" in HUD
   Else:
     Toggle bIsOpen
     If bIsOpen: Rotate DoorMesh 90° over 0.5s (Timeline)
     If !bIsOpen: Rotate DoorMesh back 0° over 0.5s (Timeline)
     Play door sound
   ```
6. **GetInteractionText**: Return `InteractionText`
7. **CanInteract**: Return `True` (always interactable, but locked status checked in Interact)

---

## STEP 5: Keycard — BP_Keycard

1. Open `Content/Blueprints/Interactables/BP_Keycard`
2. **Implement Interface**: BPI_Interactable
3. **Components**:
   - Static Mesh: small flat rectangle, colored material (Red/Blue/Green)
   - Sphere Collision
   - Rotating Component (optional, makes it spin to look pickable)
4. **Variables**:
   ```
   KeycardID   Integer = 1  (1=red, 2=blue, 4=green)
   bPickedUp   Boolean = false
   ```
5. **Interact**:
   ```
   If NOT bPickedUp:
     PlayerRef.CurrentKeycard = OR(PlayerRef.CurrentKeycard, KeycardID)
     bPickedUp = True
     Hide Static Mesh, Disable Collision
     Play pickup sound
     Update HUD: Show "Keycard picked up!"
   ```
6. **GetInteractionText**: Return `"Press E to Pick Up Keycard"`

---

## STEP 6: Power Relay — BP_PowerRelay

1. Open `Content/Blueprints/Interactables/BP_PowerRelay`
2. **Implement Interface**: BPI_Interactable
3. **Components**:
   - Static Mesh: wall panel (use cube or cylinder)
   - Point Light: dim red when inactive, bright green when active
   - Box Collision
4. **Variables**:
   ```
   bIsActivated  Boolean = false
   RelayID       Integer (0-based index for tracking)
   ```
5. **Interact**:
   ```
   If NOT bIsActivated:
     bIsActivated = True
     Set Light Color to Green, Increase Intensity
     Play activation sound
     Notify BP_ObjectiveManager: RelayActivated(RelayID)
   ```
6. **GetInteractionText**: 
   ```
   If bIsActivated: Return "RELAY ACTIVE"
   Else: Return "Press E to Activate Relay"
   ```

---

## STEP 7: Keypad — BP_Keypad

1. Open `Content/Blueprints/Interactables/BP_Keypad`
2. **Implement Interface**: BPI_Interactable
3. **Components**:
   - Static Mesh: wall panel
   - Box Collision
4. **Variables**:
   ```
   CorrectCode     String = "0452"
   LinkedDoor      Actor Reference → BP_Door
   bSolved         Boolean = false
   ```
5. **Interact**:
   ```
   Create WBP_KeypadInput widget, Add to Viewport
   Set Input Mode: UI and Game
   WBP_KeypadInput stores a reference to this BP_Keypad
   ```
6. **CheckCode(InputCode: String)**:
   ```
   If InputCode == CorrectCode:
     bSolved = True
     Open LinkedDoor (call Interact on it, or directly set bIsOpen=true)
     Play success sound, Show "ACCESS GRANTED"
     Remove keypad widget
   Else:
     Play error sound, Show "INCORRECT CODE - Try Again"
     Clear input in widget
   ```

---

## STEP 8: WBP_KeypadInput Widget

1. Create a simple UI:
   - Background panel (dark, translucent)
   - Text block showing entered digits: "_ _ _ _"
   - Buttons 0-9
   - DELETE button
   - ENTER button
   - CANCEL button (closes widget)
2. Logic:
   - Store entered string (max 4 chars)
   - On ENTER: Call linked BP_Keypad.CheckCode(entered string)
   - On CANCEL: Remove from viewport, restore Game input mode
   - On DELETE: Remove last char from string

---

## STEP 9: BP_ObjectiveManager

1. Open `Content/Blueprints/Core/BP_ObjectiveManager`
2. **Variables**:
   ```
   TotalRelays      Integer = 3
   ActivatedRelays  Integer = 0
   bPowerRestored   Boolean = false
   bKeycodeEntered  Boolean = false
   bEscapeReached   Boolean = false
   ObjectiveText    String = "Find a way out"
   ```
3. **Functions**:
   - `RelayActivated(RelayID)`:
     ```
     ActivatedRelays++
     Update HUD progress bar: ActivatedRelays/TotalRelays
     If ActivatedRelays >= TotalRelays:
       bPowerRestored = True
       Update ObjectiveText = "Power restored! Find the exit"
       Unlock the area gate/door (call on a specific door reference)
     ```
   - `KeycodeEntered()`:
     ```
     bKeycodeEntered = True
     Update ObjectiveText = "Escape through the secure corridor"
     ```
   - `GetRelayProgress()` returns Float = ActivatedRelays/TotalRelays

---

## STEP 10: BP_RealityManager

1. Open `Content/Blueprints/Core/BP_RealityManager`
2. **Variables**:
   ```
   bIsCorruptedReality  Boolean = false
   NormalRealityActors  Array of Actor References
   CorruptedRealityActors Array of Actor References
   NormalLights         Array of Light Component References
   CorruptedLights      Array of Light Component References
   ShiftCooldown        Float = 1.5
   bCanShift            Boolean = true
   ```
3. **ShiftReality() function**:
   ```
   If NOT bCanShift: Return
   
   bIsCorruptedReality = NOT bIsCorruptedReality
   bCanShift = False
   
   For each actor in NormalRealityActors:
     SetActorHiddenInGame(bIsCorruptedReality)
     SetActorEnableCollision(NOT bIsCorruptedReality)
   
   For each actor in CorruptedRealityActors:
     SetActorHiddenInGame(NOT bIsCorruptedReality)
     SetActorEnableCollision(bIsCorruptedReality)
   
   Notify all listening actors: OnRealityShifted(bIsCorruptedReality)
   
   If bIsCorruptedReality:
     Set Post Process: glitch overlay, desaturate, red tint
     Play shift sound (distorted)
   Else:
     Reset Post Process to normal
     Play shift sound (cleaner)
   
   Delay (ShiftCooldown): bCanShift = True
   
   Notify player HUD: Update reality indicator
   ```
4. **In BeginPlay**:
   - Set initial state: Show NormalRealityActors, Hide CorruptedRealityActors
5. **Tags setup**: Give this actor the tag `RealityManager` so BP_PlayerCharacter can find it with `GetActorWithTag`

---

## STEP 11: BP_Subject0 (Enemy AI)

1. Open `Content/Blueprints/AI/BP_Subject0`
2. **Components**:
   - Character Mesh (use Mannequin or any humanoid)
   - Capsule Collision (default character)
   - Point Light (ominous red glow, dim)
   - Audio Component (enemy proximity sound)
3. **Set AIController**: `BP_Subject0_AIController`
4. **Variables**:
   ```
   PatrolPoints        Array of Actor References (BP_PatrolPoint)
   CurrentPatrolIndex  Integer = 0
   PatrolSpeed         Float = 250.0
   ChaseSpeed          Float = 550.0
   AttackRange         Float = 120.0
   DetectionRange      Float = 800.0
   SightAngle          Float = 90.0  (half-angle)
   LastKnownLocation   Vector
   AIState             Enum: Patrol, Investigate, Chase, Attack, Search
   SearchTime          Float = 5.0
   SearchTimer         Float = 0.0
   bPlayerDetected     Boolean = false
   ```
5. **AIState Enum**: Create it in Content Browser: Right-click → Blueprint → Enumeration → Name `E_AIState`
   - Values: Patrol, Investigate, Chase, Attack, Search

6. **State Machine in Tick**:
   ```
   Switch on AIState:
   
   PATROL:
     MoveToActor(PatrolPoints[CurrentPatrolIndex], PatrolSpeed)
     If reached: CurrentPatrolIndex = (CurrentPatrolIndex+1) % PatrolPoints.Length
     Check for player: LineTraceSingle to Player location
       If can see player: AIState = Chase, bPlayerDetected = True
     
   INVESTIGATE:
     MoveToLocation(LastKnownLocation, PatrolSpeed)
     If reached: AIState = Search, SearchTimer = SearchTime
     
   CHASE:
     Get Player Location → LastKnownLocation
     MoveToActor(Player, ChaseSpeed)
     Distance to Player < AttackRange? → AIState = Attack
     Lost sight (trace fails) for 2 sec? → AIState = Search, SearchTimer = SearchTime
     
   ATTACK:
     Stop movement
     Play attack animation / sound
     Notify Player: PlayerDied()
     After 1 sec: AIState = Patrol (reset)
     
   SEARCH:
     SearchTimer -= DeltaTime
     Look around (random rotations)
     If SearchTimer <= 0: AIState = Patrol
   ```

7. **CanSeePlayer() function**:
   ```
   Get Player location, Get self location
   Angle = AngleBetween(ForwardVector, DirectionToPlayer)
   If Angle > SightAngle: Return False
   Distance = VectorLength(Player - Self)
   If Distance > DetectionRange: Return False
   LineTrace to Player (channel: Visibility)
   If trace hits Player: Return True
   If trace distance < 300 (proximity): Return True (heard)
   Return False
   ```

8. **Near-death sound trigger**: 
   - In Tick: If Distance to Player < 500, set Audio volume high
   - If Distance > 1000, set Audio volume low

---

## STEP 12: BP_Subject0_AIController

1. Open `Content/Blueprints/AI/BP_Subject0_AIController`
2. Simple controller — the state machine lives in BP_Subject0
3. In `BeginPlay`: Run Behavior (just delegate to Pawn)
4. Optional: Override `OnPossess` to initialize the patrol

---

## STEP 13: UI Widgets

### WBP_MainMenu
Layout:
```
Vertical Box:
  Text: "GLITCH//SHIFT" (large, horror font if available, else default)
  Text: "DON'T LOOK BACK" (smaller)
  Text: "by MysticCode"
  Button "START GAME" → OpenLevel("FacilityMap")
  Button "QUIT" → QuitGame
```

### WBP_GameHUD
Layout:
```
Canvas Panel:
  Top-Left:  Progress Bar (Power Relays) + Text "POWER: 0/3"
  Top-Center: Text Block (ObjectiveText) - updated by ObjectiveManager
  Top-Right:  Text "KEYCARD: [icon/count]"
  Bottom-Left: Text "[NORMAL] or [CORRUPTED]" - updated by RealityManager
  Bottom-Center: Text "[E] to interact..." - shown when trace hits interactable
  Bottom-Right: Text "STAMINA: [bar]" (optional)
```
- Functions:
  - `UpdateObjective(Text)` — sets objective text
  - `UpdateRelayProgress(Current, Total)` — sets progress bar
  - `ShowInteractionPrompt(Text)` / `HideInteractionPrompt()`
  - `UpdateRealityState(bCorrupted)` — changes text/color
  - `UpdateKeycard(Count)` — shows keycard status

### WBP_PauseMenu
Layout:
```
Background (dark translucent)
Text: "PAUSED"
Button "RESUME" → Close widget, Unpause
Button "RESTART" → OpenLevel(current)
Button "MAIN MENU" → OpenLevel("MainMenu")  
Button "QUIT" → QuitGame
```

### WBP_DeathScreen
Layout:
```
Background (black with red overlay)
Text: "YOU WERE CAPTURED"
Text: "SUBJECT 0 HAS YOU"
Button "TRY AGAIN" → OpenLevel(current)
Button "MAIN MENU" → OpenLevel("MainMenu")
```
- Add 1-second fade-in delay before showing buttons

### WBP_VictoryScreen
Layout:
```
Background (dark with fading white)
Text: "YOU ESCAPED"
Text: "PROJECT NULL... CONTAINED."
Text: "MysticCode - GLITCH//SHIFT: DON'T LOOK BACK"
Button "PLAY AGAIN" → OpenLevel("FacilityMap")
Button "MAIN MENU" → OpenLevel("MainMenu")
```

---

## STEP 14: Create Maps

### Create MainMenu map:
1. File → New Level → Empty Level
2. Save as `/Game/Maps/MainMenu`
3. Place a simple backdrop mesh
4. In World Settings → Game Mode Override: `BP_GameMode`
5. Add a Level Blueprint:
   - BeginPlay: Create WBP_MainMenu, Add to Viewport, Set Input Mode UI Only, Show Mouse Cursor

### Create FacilityMap (main gameplay level):
1. File → New Level → Empty Level (or Default)
2. Save as `/Game/Maps/FacilityMap`
3. In World Settings → Game Mode Override: `BP_GameMode`

#### Level Layout (blockout with BSP/Static Meshes):
Use BSP brushes or simple cube static meshes to build:

**Area 1 — Facility (Tutorial):**
- Room 1: Player start, containment cell (small room 400x400x300)
- Corridor: 200x800x300 leading north
- Note on wall: Research Log 01
- BP_Door (unlocked) at end of corridor
- BP_Flashlight tutorial trigger

**Area 2 — Wrong Floor (Puzzle 1: Reality Shift):**
- Large room 600x600x300
- Normal reality: north door is locked, west passage blocked
- Corrupted reality: west passage opens, alternate route reveals Power Cell/Relay
- Place BP_PowerRelay (Relay 1)
- BP_Door (CorruptedOnly) on west wall
- Note on table: Security Report

**Area 3 — Subject 0 Area (Puzzle 2: Power Restoration):**
- Interconnected corridors forming a loop
- Place BP_PowerRelay (Relay 2) in alcove
- Place BP_PowerRelay (Relay 3) in server room
- Place BP_Subject0 with 3-4 patrol points
- Main door out is locked until all relays activated
- Note: Research Log 02

**Area 4 — Don't Look Back (Finale):**
- Long corridor 200x2000x250
- Lights placed sparsely (should feel like they're failing)
- BP_Keypad at the end (code is 0452, found written on wall mid-corridor)
- Note: "Reality Keycode: 0452" on wall (can't miss it)  
- BP_ExitElevator at end (calls VictoryScreen and level reload)
- Subject 0 should be patrolling near start of this corridor
- Final Recording note at entrance

#### NavMesh:
1. Place a Nav Mesh Bounds Volume covering the entire level
2. Build → Build Navigation
3. Verify NavMesh shows in viewport (press P to toggle NavMesh display)

#### Lighting:
**Normal Reality:**
- Sparse ceiling lights, cold white-blue color
- Some flickering lights (use BP_FlickerLight or Matinee)
- Set overall luminance to be dim (horror atmosphere)

**Corrupted Reality (when shifted):**
- Additional post-process volume: Red tint, chromatic aberration, film grain
- Some lights turn off, others flicker more aggressively
- BP_RealityManager controls this via light component references

#### Place all actor instances:
- 1x BP_RealityManager (anywhere, give it `RealityManager` tag)
- 1x BP_ObjectiveManager (anywhere, give it `ObjectiveManager` tag)  
- 3x BP_PowerRelay
- 1x BP_Keypad (linked to the final corridor door)
- 4x BP_Note (Research logs)
- 2x BP_Door (locked doors, one requiring keycard)
- 1x BP_Keycard (blue keycard in Area 2)
- 1x BP_Subject0 + 4x BP_PatrolPoint
- 1x BP_ExitElevator
- 1x PlayerStart (at beginning of Area 1)

#### Set BP_RealityManager references:
- In its Details panel, populate `NormalRealityActors` and `CorruptedRealityActors` arrays with the paired actors

---

## STEP 15: Note Content (In-Game Lore)

### Note: Research Log 01 — PROJECT NULL
```
DATE: [REDACTED]
PROJECT: NULL - Parallel State Research

Day 847. The boundary has been weakening for weeks.
The scanner readings confirm what we feared — PROJECT NULL 
has destabilized the quantum membrane separating our reality 
from the corrupted parallel state.

We need to shut down the reactor before the states collapse 
entirely. Power cells are located throughout Level 3.

If anyone finds this: RESTORE THE POWER. THE EXIT IS ON LEVEL 4.
— Dr. Chen
```

### Note: Security Report — Containment Breach
```
SECURITY LOG - LEVEL 3
ALERT: SUBJECT 0 CONTAINMENT BREACH

Subject 0 is no longer in its cell.
Last known: Server Corridor B, heading toward labs.

DO NOT ENGAGE. SUBJECT 0 IS HIGHLY DANGEROUS.
Use Reality Shift to navigate alternate corridors.
It cannot follow you between states... yet.

— Security Chief Mavros
```

### Note: Research Log 02 — Subject 0
```
SUBJECT: ENTITY 0 / "NULL-WALKER"
STATUS: ACTIVE / UNCONTAINED

Subject 0 is a manifestation of the corrupted reality given form.
It emerged from the membrane rupture on Day 801.

Observations:
- Navigates both reality states
- Attracted to movement and sound  
- Cannot be reasoned with
- Pursuit intensifies in corrupted reality

CRITICAL WARNING:
If it catches you in corrupted reality, you will not come back.
```

### Note: Final Recording — Reality Collapse
```
[VOICE RECORDING - PARTIALLY CORRUPTED]

This is Director Marsh. If you're hearing this...
the facility has already gone.

The code to the secure corridor is...
[STATIC] ...four, five, two...

No wait. It was zero-four-five-two.

RUN. Don't stop. Don't look back.
Once you hear it behind you, just
DON'T
LOOK
BACK.

[END OF RECORDING]
```

---

## STEP 16: Audio Setup

If audio assets are available (WAV/OGG files):

1. Import audio files: Content Browser → Import → Select WAV files
2. Create Sound Cue assets for complex sounds (e.g., footsteps with randomization)
3. Assign in Blueprints:
   - BP_PlayerCharacter: Footstep sound (on movement)
   - BP_Door: Open/close sound
   - BP_PowerRelay: Activation sound  
   - BP_RealityManager: Shift sound, ambient (2 versions: normal/corrupted)
   - BP_Subject0: Proximity heartbeat (Audio Component), Chase music
   - WBP_DeathScreen: Death sound
   - WBP_VictoryScreen: Escape sound

If no audio assets: The game works without audio. Document missing sounds in TEST_CHECKLIST.md.

---

## STEP 17: Don't Look Back Sequence

In the Level Blueprint for FacilityMap, create a trigger volume at the entrance to Area 4:
1. Box Trigger Volume → OnActorBeginOverlap (with BP_PlayerCharacter)
2. Sequence of events:
   - Play distorted announcement audio (if available): "WARNING: FACILITY COLLAPSE IMMINENT"
   - Set Subject 0 AIState = Chase (force chase mode)
   - Move Subject 0 to Area 4 entrance (Teleport or force its start location)
   - Flicker all lights in Area 4 (Timeline: On→Off rapidly)
   - HUD shows: "RUN! DON'T LOOK BACK!"

---

## STEP 18: Save All & Verify

1. **Save All**: File → Save All (Ctrl+S)
2. **Compile All Blueprints**: Go to each Blueprint, click Compile
3. **Build Navigation**: Build → Build Navigation
4. **Build Lighting**: Build → Build Lighting Only (or just run without built lighting for prototype)
5. **Play in Editor**: Click the Play button
6. Test: Movement, flashlight, interaction, reality shift, doors, keypad, enemy, HUD

---

## STEP 19: Git Commit

After the above is working, commit from the project directory:
```bash
git add Config/ Content/ Scripts/ .gitignore .uproject *.md
git status  # verify only intended files staged
git commit -m "feat: implement core gameplay systems and level layout"
git push origin master
```

**IMPORTANT**: Make sure `.gitignore` excludes Intermediate/, Saved/, DerivedDataCache/

---

## COMMON ISSUES & FIXES

| Issue | Fix |
|-------|-----|
| Blueprint won't compile | Check for missing variable references, null actor refs |
| Player can't move | Check IMC_MysticCode is added in BeginPlay, Input Actions bound |
| Interaction doesn't work | Verify BPI_Interactable is implemented on target actor |
| Enemy stuck | Make sure NavMesh covers the area, rebuild navigation |
| Reality shift crashes | Ensure arrays are populated, add null checks before hiding actors |
| Keypad won't open door | Check `LinkedDoor` reference is set in BP_Keypad details |
| Game opens to empty level | Set FacilityMap as Editor Startup Map in Project Settings |
| Push fails (large file) | Run `git status`, ensure Intermediate/ and Saved/ are gitignored |