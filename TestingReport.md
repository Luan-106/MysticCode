# Testing report — Godot project

## Inspected starting state

- The original Unity project is at `outputs/GLITCH_SHIFT`; it remains untouched.
- The Godot project is at `outputs/GLITCH_SHIFT_GODOT`, standalone outside the Unity project tree.
- The installed Godot version is 4.7.2.

## Fixes made after Godot reported script-load errors

- Replaced invalid `PackedVector2Array(Vector2, ...)` constructors in the reality platform and hazard scripts with array-based construction.
- Fixed an invalid mixed string/numeric `Color(...)` constructor in the level background script.
- Duplicated each platform and hazard collision shape before changing its size, preventing instances from sharing one mutable shape resource.

## Checks performed

- Godot 4.7.2 headless startup of `res://scenes/the_forgotten_facility.tscn` for 20 frames: **passed**, exit code 0 with no parser/runtime errors in output.
- Opened the project in the Godot editor and launched the scene with F6; the debug game window rendered the facility and HUD.
- Static file reference audit: all literal `res://` script, scene, and preload paths resolve to files in the project.
- Full objective flow, collision feel, reality-switch edge cases, and Windows export were not verified.
## Seven-stage update

- Added seven named stages with persistent stage progression through the shared main scene. Relay-powered exits advance stages; the seventh exit triggers the existing escape screen.
- Each stage adds another reality-specific hazard, later levels add more Subject 0 pursuers, and Subject 0 detection/patrol/chase speeds rise with stage number.
- Added current stage/title to the HUD and generated level intro.
- Godot 4.7.2 headless startup of the updated main scene for 20 frames: passed with exit code 0 and no script/runtime errors in the captured log. Full playthrough and stage-by-stage balance remain unverified.

## Progression correction

- Powered exits advance automatically when the player reaches them; pressing E at the exit still works.
- Losing all health resets the current stage to Level 1, clears objectives, shows a short run-lost panel, and reloads the level.
- Updated main scene launched in the Godot editor and rendered Level 1 / 7. Updated headless startup: exit code 0, no script/runtime errors. Stage transition and death loop have not been played through end-to-end.

## Subject 0 sprite update

- Added assets/enemies/subject_zero.png, a transparent teal-lit creature sprite based on the attached concept sheet, and replaced the placeholder Polygon2D in scenes/subject_zero.tscn with a Sprite2D using that texture.
- Godot imported the PNG and the updated main scene launched headlessly for 30 frames with exit code 0 and no script/runtime errors. Opened the updated game in Godot and visually confirmed the upright sprite renders at the intended size in Level 1.

## Player art and movement animation

- Added assets/player/survivor_concept_sheet.png, matched to the survivor on the supplied concept sheet, and connected it in scenes/player.tscn.
- Added procedural idle breathing, run bob, jump lean, attack lean, and dash pose motion for the player, plus state-based patrol/chase/attack motion for Subject 0.
- Godot 4.7.2 headless launch of the main scene completed with exit code 0 and no script errors. The sandbox prevented Godot from writing its user://logs/godot.log; the project load still completed. Visual gameplay animation has not been reviewed frame by frame.

## Concept-sheet player update

- Replaced the player scene texture with the isolated survivor design based on the supplied concept sheet. Godot imported the new PNG and the main scene launched with exit code 0 and no script errors. The game process opened with the debug window title GLITCH//SHIFT: DONT LOOK BACK.

- Used the Godot editor to stop and relaunch the facility scene after importing the concept-matched survivor; visually confirmed the updated player sprite beside Subject 0 in the running debug game window.

## Rainy background and movement update

- Cropped the environment panorama from the supplied concept sheet into assets/backgrounds/forgotten_facility_panorama.png and draw it behind the corridor architecture.
- Expanded player run stride/sway, jump squash and stretch, idle breathing, attack lean, and dash pose. Expanded Subject 0 patrol/chase strides, attack lunge, and recovery recoil.
- Reloaded the project in Godot 4.7.2, launched the facility scene, and visually confirmed the rainy panorama, player sprite, and moving Subject 0 in the running game window.

## Comic prologue update

- Added the supplied ten-panel comic storyboard at `assets/intro/between_two_realities_comic.png` and replaced the opening transcript page with six animated comic pages plus a title/start card.
- Added typed captions, staggered panel pop-in/tilt, comic impact lettering, and short color-glitch flashes. Enter/Space/click reveal and advance; Esc skips. The intro remains connected to the existing paused-before-gameplay opening flow.
- Godot 4.7.2 headless launch of the main scene for 180 frames: passed with no parser or runtime errors. The sandbox blocked the default roaming settings folder on the first editor scan, so the game check used temporary writable AppData paths. Visual presentation and the full intro-to-gameplay transition were not manually reviewed.
