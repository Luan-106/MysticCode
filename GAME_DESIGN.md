# Game Design Document - GLITCH//SHIFT: DON'T LOOK BACK

## Game Overview
**Genre:** First-person psychological horror  
**Gameplay:** Exploration, environmental puzzles, survival, stealth  
**Duration:** 10-20 minutes (prototype)  
**Perspective:** First-person  

## Core Premise
The player awakens in an abandoned research facility after PROJECT NULL shattered the boundary between reality and a corrupted parallel state. The facility has lost power, security systems are malfunctioning, and hallways change when shifting between realities. SUBJECT 0 escaped containment. The player must restore power, solve puzzles, avoid the enemy, and escape before the corrupted reality consumes the facility.

## Central Mechanic: Reality Shift
Pressing Q toggles between two reality states:

### Normal Reality
- Relatively stable lighting
- Readable environmental clues and notes
- Some doors, switches, or routes are unavailable
- Calmer audio atmosphere

### Corrupted Reality
- Flickering lights and distorted atmosphere
- Alternate routes, hidden clues, and additional interactable objects
- Increased danger from Subject 0 (more aggressive, wider detection)
- Distorted audio with static and glitch effects
- Visual glitch effects and color grading changes

**Transition:** Smooth screen-space effect with audio cue. Player remains in same location. Geometry changes occur via paired actors/visibility changes.

## Level Flow

### 1. FACILITY (Awakening & Tutorial)
- Player awakens in a containment cell
- Flashlight tutorial
- First notes and clues about PROJECT NULL
- First interactive door tutorial
- Introduction to Reality Shift mechanic
- First glimpse of distorted corridors

### 2. WRONG FLOOR (Reality-Shift Introduction)
- Hallways that look different in each reality
- Access puzzle requiring reality switching
- Alternate route reveals a power cell
- Environmental storytelling about the experiment's failure
- First encounter with audio cue indicating danger

### 3. SUBJECT 0 (Enemy Encounter & Power Restoration)
- Subject 0 patrols a security corridor
- Power Restoration puzzle must be completed to progress
- Subject 0 becomes more active when power is restored
- Chase sequence through the facility
- Player must use Reality Shift to escape corridors

### 4. DON'T LOOK BACK (Final Escape)
- Diminishing lights as the facility collapses
- Final chase sequence toward the exit
- The core rule is enforced: looking back increases danger
- Safe room or exit door as the endpoint
- Ending sequence

## Gameplay Systems

### Player Character
- First-person camera with mouse look
- WASD movement with variable speed
- Sprint (Left Shift) with stamina meter
- Flashlight (F) with optional battery drain
- Reality Shift (Q) with visual/audio feedback
- Crouch (C) for stealth
- Interaction (E) with prompt system

### Interaction System
- Trace from camera camera location forward
- Detect objects with `BPI_Interactable` interface within range (default: 500 units)
- Display prompt: "Press E to [action]"
- Prevent trace hits against pawn/player collision
- Interface supports: OpenDoor, UseKeycard, ReadNote, ActivateRelay, InputCode, ExitLevel

### Doors
- Simple doors: Play open/close animation, toggle collision
- Locked doors: Require corresponding keycard
- Keycard: Inventory item, consumed or reusable depending on design
- Door sound effects on open/close
- Animated door mesh or simple rotation

### Power Relays (Puzzle 1)
- Scattered throughout the facility
- Player must find and activate all relays
- Activation state tracked by `BP_ObjectiveManager`
- Correct activation unlocks the next area
- Visual indicator shows which relays are activated

### Keypad / Reality Keycode (Puzzle 2)
- Code discovered through environmental clues (notes, graffiti, etc.)
- Default code: 0452 (example, determined by level design)
- Keypad inputs digits 0-9
- Correct code opens the locked route
- Incorrect code: visual/shake feedback, "Try again" message
- Unlimited attempts until code is correct

### Subject 0 AI
**Behavior States:**
1. **PATROL** - Move among 3-4 designated patrol points using NavMesh
2. **INVESTIGATE** - React to detected player or event; search area
3. **CHASE** - Pursue player when detected; follow NavMesh path
4. **ATTACK** - Trigger when close enough; death/capture sequence
5. **SEARCH** - Briefly search player's last known position before returning to patrol

**Detection:**
- Line-of-sight check (if player visible within 180-degree arc)
- Proximity check (within 300 units)
- Audio cue when player is detected

**Audio/Visual Warnings:**
- Subtle heartbeat sound when enemy is nearby (getting louder as player gets closer)
- Visual silhouette or glow effect on walls when enemy is close
- Distorted radio/static sound when enemy detects player

### Death and Restart
- When Subject 0 catches the player, a capture sequence triggers
- Death screen fades to black with "YOU WERE CAPTURED" text
- Restart option returns to last checkpoint or start of current area
- All puzzle states reset
- Enemy returns to patrol positions
- Player respawns at last activated checkpoint

### UI System
**Main Menu:**
- Game title: GLITCH//SHIFT: DON'T LOOK BACK
- Start Game button
- Credits/Options

**HUD:**
- Current objective text (top center)
- Interaction prompt (bottom center, when applicable)
- Keycard status (top right, shows count)
- Power-relay progress (top left, progress bar)
- Reality-state indicator (bottom left: NORMAL/CORRUPTED)
- Stamina bar (bottom center, if implemented)

**Pause Menu:**
- Resume game
- Restart level
- Main menu
- Quit game

**Death Screen:**
- "YOU WERE CAPTURED" or similar text
- Restart button
- Main menu button

**Victory/Escape Screen:**
- "YOU ESCAPED" text
- Credits or exit to main menu

### Audio and Atmosphere
- Ambient facility hum (constant low-frequency sound)
- Flickering electrical sound (more frequent in corrupted reality)
- Footstep sounds (different surfaces: concrete, metal, flesh)
- Door sounds (creaking open, slamming shut)
- Reality-shift sound (glitch/transition effect)
- Enemy proximity cue (heartbeat increasing in speed)
- Chase music (intensified ambient track)
- Death sound (distorted scream or static)
- Escape sound (successful whoosh or air rush)

### Story Documents (Optional Notes)
- **Research Log 01: PROJECT NULL** - Describes the experiment that destroyed reality boundaries
- **Security Report: Containment Breach** - Details about Subject 0's escape
- **Research Log 02: Subject 0** - Information about the subject and its abilities
- **Final Recording: Reality Collapse** - Last entry from the facility director

## Technical Notes

### Project Architecture
- **BP_PlayerCharacter** - Character class with camera, input handling
- **BPI_Interactable** - Interface for interactable objects
- **BP_ObjectiveManager** - Singleton-like manager for tracking objectives
- **BP_RealityManager** - Handles reality shift state and environment changes
- **BP_GameMode** - Game rules and restart logic

### Navigation
- NavMesh baked for the level layout
- Enemy AI uses NavMesh for navigation
- Patrol points are simple actor locations

### Graphics
- Two lighting setups: Normal and Corrupted
- Corrupted reality uses post-process materials for glitch effects
- Flashlight adds dynamic light with range falloff
- Screen-space effects for reality transition

### Performance
- Keep AI simple for game-jam build
- Use level streaming sparingly (one large map is fine for prototype)
- Limit real-time effects to maintain 60fps target