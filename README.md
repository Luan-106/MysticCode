# GLITCH//SHIFT: DON'T LOOK BACK — Godot prototype

A Godot 4.x GDScript horror-platformer jam prototype with a seven-stage run and rising difficulty. The Godot project is in `outputs/GLITCH_SHIFT_GODOT`. The earlier Unity project remains untouched in `outputs/GLITCH_SHIFT`.

## Run

1. Install and open **Godot 4.x** and choose **Import** in the Project Manager.
2. Select this folder (the one containing `project.godot`). Use the Compatibility renderer if prompted; the project is configured for it.
3. Let Godot finish scanning scripts, then run the project with **F6/F5** or the top-right Play button. `scenes/the_forgotten_facility.tscn` is configured as the main scene.

## Opening story

An animated comic-book PROJECT NULL prologue plays before the first level, using the supplied ten-panel storyboard. Panels slide and pop into comic frames, with typewritten narration, impact lettering, rain, and brief reality-glitch flashes. Press **Enter/Space** or click to reveal/advance; press **Esc** to skip. Restart Run replays the introduction.

## Controls

- A/D or Left/Right: move
- Space, W or Up: jump; release early for a shorter jump
- Shift: dash
- J or left mouse button: melee attack
- Q: switch Stable/Corrupted reality
- E: interact with the nearest item
- Escape: pause/resume

## Play through

Collect each amber fuse, then use **E** at the corresponding teal relay. Restore all three relays, then walk into the emergency exit to advance automatically through seven stages. A run loss resets you to stage 1 and clears that stage's objectives. Each stage adds hazards; later stages add faster, more perceptive Subject 0 pursuers. Reach Project Null Core (stage 7) to escape. Use **Q** to reveal the corrupted bridge and the stepwell stairs. The switch is refused if a newly appearing platform or hazard would overlap the player. The red marker records a checkpoint, but a full run loss returns you to stage 1. **Restart Run** also resets to stage 1. Subject 0 patrols, detects and chases the player, then attacks within range. Pursuit speed and detection range rise by stage, and additional Subject 0 encounters appear later.

## Current implementation

- `scenes/the_forgotten_facility.tscn`: main scene reused to generate seven distinct stages, with the current title and difficulty shown in the HUD.
- `scenes/player.tscn`, `subject_zero.tscn`, `platform.tscn`, `hazard.tscn`, `interactable.tscn`, and `hud.tscn` are reusable scenes.
- `scripts/player`: buffered jump, coyote time, variable jump, dash, wall slide/jump, melee overlap, knockback, health and invulnerability.
- `scripts/reality`: stable/corrupted platform and hazard activation with an overlap safety check before shifting.
- `scripts/enemies`: Subject 0 patrol/chase/attack/recovery states.
- `scripts/interactables`: fuses, fuse-gated relays, checkpoint, research record, and exit.
- `scripts/core`: shared run state and level layout/background.
- `scripts/ui`: animated comic prologue, health/objective/reality HUD, interaction prompt, pause, death, restart, and victory overlays.
- Each stage has its own route geometry, fuse/relay placements, hazards, and architectural motif; a new run seed shifts routes and objectives so layouts vary without reusing a chapter layout within that run. A full-screen monsoon industrial panorama sits behind the corridor from ceiling to floor, with rain, flickering lights, bilingual warning paint, and stage-specific architecture. The player and Subject 0 use four-frame walk cycles derived from the supplied concept art; the player switches to the walk cycle while moving, and Subject 0 uses it while patrolling or chasing. Their idle, jump, attack, and dash poses retain procedural motion. Rain/intercom/metal motifs still need audio.

## Validation status

Godot 4.7.2 was used to load the project and launch the main scene. The GDScript constructor errors found during startup were fixed. See `TestingReport.md` for the checks performed and remaining gameplay verification.
