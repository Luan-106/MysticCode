extends Node2D

const PLATFORM_SCENE := preload("res://scenes/platform.tscn")
const HAZARD_SCENE := preload("res://scenes/hazard.tscn")
const OBJECT_SCENE := preload("res://scenes/interactable.tscn")
const ENEMY_SCENE := preload("res://scenes/subject_zero.tscn")
const HUD_SCENE := preload("res://scenes/hud.tscn")
const INTRO_SCENE := preload("res://scenes/intro_cinematic.tscn")
const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/forgotten_facility_panorama.png")

# Each chapter has its own traversal rhythm, object route, and hazard language.
# Small seeded shifts make each fresh run feel different without repeating a chapter layout.
const LEVEL_LAYOUTS := [
	{"width": 2820.0, "light_spacing": 440, "shaft": 1180.0,
	 "stable": [[500, 500, 112], [920, 462, 138], [1450, 505, 98], [1900, 455, 138], [2380, 490, 122]],
	 "corrupt": [[620, 430, 130], [1080, 390, 118], [1530, 445, 126], [2070, 390, 146], [2510, 438, 110]],
	 "fuses": [270, 1010, 2360], "relays": [560, 1530, 2640], "checkpoint": 1190, "record": 1370,
	 "hazards": [[690, 1, 66], [1790, 0, 70], [2220, 1, 86]], "enemies": [940]},
	{"width": 3100.0, "light_spacing": 390, "shaft": 700.0,
	 "stable": [[430, 465, 150], [760, 380, 115], [1110, 465, 164], [1530, 355, 125], [1940, 455, 150], [2350, 370, 132], [2760, 465, 170]],
	 "corrupt": [[590, 415, 102], [930, 315, 146], [1300, 410, 115], [1730, 305, 160], [2150, 405, 118], [2570, 320, 150]],
	 "fuses": [360, 1190, 2460], "relays": [730, 1690, 2780], "checkpoint": 1460, "record": 2220,
	 "hazards": [[900, 0, 72], [1380, 1, 104], [2020, 0, 86], [2650, 1, 104]], "enemies": [1000, 2240]},
	{"width": 3260.0, "light_spacing": 520, "shaft": 2470.0,
	 "stable": [[410, 500, 170], [810, 415, 115], [1280, 495, 124], [1780, 405, 156], [2240, 490, 116], [2730, 400, 172]],
	 "corrupt": [[610, 440, 106], [1050, 350, 158], [1510, 455, 120], [1990, 340, 144], [2470, 430, 108], [2930, 350, 158]],
	 "fuses": [310, 1030, 2500], "relays": [650, 1580, 2860], "checkpoint": 1810, "record": 1220,
	 "hazards": [[540, 2, 170], [1120, 2, 120], [1810, 2, 210], [2360, 2, 150], [2910, 2, 190]], "enemies": [1660, 2590]},
	{"width": 3440.0, "light_spacing": 350, "shaft": 1710.0,
	 "stable": [[450, 480, 130], [850, 420, 110], [1230, 360, 110], [1600, 300, 100], [1990, 360, 110], [2370, 420, 110], [2810, 480, 130]],
	 "corrupt": [[640, 435, 106], [1020, 375, 106], [1410, 315, 106], [1800, 255, 106], [2180, 315, 106], [2580, 375, 106], [3030, 435, 106]],
	 "fuses": [420, 1370, 2810], "relays": [840, 2020, 3250], "checkpoint": 1710, "record": 1110,
	 "hazards": [[710, 1, 72], [1170, 0, 72], [1640, 1, 76], [2110, 0, 72], [2580, 1, 82], [3070, 0, 78]], "enemies": [1140, 2290]},
	{"width": 3580.0, "light_spacing": 410, "shaft": 2870.0,
	 "stable": [[430, 450, 130], [900, 355, 130], [1370, 465, 130], [1840, 355, 130], [2310, 465, 130], [2780, 355, 130], [3220, 450, 130]],
	 "corrupt": [[650, 380, 145], [1110, 440, 105], [1580, 300, 145], [2050, 440, 105], [2520, 300, 145], [2990, 430, 145]],
	 "fuses": [300, 1280, 3000], "relays": [760, 2200, 3410], "checkpoint": 1780, "record": 2380,
	 "hazards": [[600, 1, 110], [1130, 0, 70], [1620, 1, 110], [2100, 0, 70], [2610, 1, 112], [3140, 0, 88]], "enemies": [1660, 2860]},
	{"width": 3720.0, "light_spacing": 460, "shaft": 1830.0,
	 "stable": [[440, 460, 160], [850, 370, 126], [1280, 465, 140], [1690, 375, 128], [2110, 460, 156], [2540, 365, 126], [2960, 460, 148], [3370, 370, 130]],
	 "corrupt": [[620, 400, 105], [1050, 440, 145], [1470, 315, 105], [1900, 430, 155], [2320, 305, 105], [2750, 430, 155], [3180, 315, 105]],
	 "fuses": [400, 1510, 3170], "relays": [970, 2360, 3500], "checkpoint": 1870, "record": 1280,
	 "hazards": [[720, 0, 80], [1190, 1, 110], [1650, 0, 90], [2120, 1, 120], [2580, 0, 90], [3050, 1, 120], [3460, 0, 86]], "enemies": [1450, 2730, 3260]},
	{"width": 3920.0, "light_spacing": 480, "shaft": 2500.0,
	 "stable": [[480, 470, 130], [920, 390, 142], [1380, 320, 120], [1900, 410, 156], [2370, 310, 120], [2840, 400, 148], [3340, 470, 130], [3690, 390, 118]],
	 "corrupt": [[680, 425, 112], [1130, 345, 112], [1600, 420, 140], [2110, 335, 112], [2600, 415, 144], [3080, 340, 114], [3560, 420, 140]],
	 "fuses": [350, 1740, 3360], "relays": [1090, 2560, 3740], "checkpoint": 2020, "record": 1500,
	 "hazards": [[620, 1, 92], [1210, 0, 110], [1730, 1, 138], [2260, 0, 106], [2800, 1, 138], [3310, 0, 108], [3740, 1, 94]], "enemies": [1510, 2830, 3480]}
]

var rain := PackedVector2Array()
var rain_rng := RandomNumberGenerator.new()
var layout_rng := RandomNumberGenerator.new()
var flicker := 1.0
var flicker_clock := 0.0
var world_width := 2820.0
var stage := 1
var layout: Dictionary = {}
var level_started := false

func _ready() -> void:
	stage = RunState.current_level
	layout = LEVEL_LAYOUTS[clampi(stage - 1, 0, LEVEL_LAYOUTS.size() - 1)]
	world_width = float(layout["width"])
	layout_rng.seed = RunState.run_seed + stage * 104729
	if stage == 1 and not RunState.intro_seen:
		get_tree().paused = true
		var intro := INTRO_SCENE.instantiate()
		intro.finished.connect(_start_level)
		add_child(intro)
	else:
		_start_level()

func _start_level() -> void:
	if level_started:
		return
	level_started = true
	get_tree().paused = false
	RunState.intro_seen = true
	_create_fullscreen_background()
	RunState.begin_level()
	_build_level()
	rain_rng.randomize()
	for i in 150 + stage * 12:
		rain.append(Vector2(rain_rng.randf_range(0.0, world_width), rain_rng.randf_range(0.0, 720.0)))
	RunState.reality_changed.connect(_on_reality_changed)
	var light_spacing: int = int(layout["light_spacing"])
	for x in range(180, int(world_width) - 120, light_spacing):
		_add_reality_light(Vector2(x, 360))
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	if camera:
		camera.limit_right = int(world_width)

func _process(delta: float) -> void:
	for i in range(rain.size()):
		var drop: Vector2 = rain[i]
		drop.y += (370.0 + stage * 12.0) * delta
		drop.x -= 58.0 * delta
		if drop.y > 730.0:
			drop = Vector2(rain_rng.randf_range(0.0, world_width), -10.0)
		rain[i] = drop
	flicker_clock += delta
	if flicker_clock > rain_rng.randf_range(0.025, 0.1):
		flicker_clock = 0.0
		flicker = rain_rng.randf_range(0.62 if stage >= 5 else 0.78, 1.0)
	queue_redraw()

func _create_fullscreen_background() -> void:
	var background_layer := CanvasLayer.new()
	background_layer.name = "FullScreenPanorama"
	background_layer.layer = -10
	add_child(background_layer)
	var background := TextureRect.new()
	background.texture = BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_layer.add_child(background)

func _draw() -> void:
	draw_rect(Rect2(0, 0, world_width, 720), Color(0.025, 0.055, 0.07, 0.12), true)
	draw_rect(Rect2(0, 415, world_width, 145), Color(0.045, 0.085, 0.09, 0.40), true)
	draw_rect(Rect2(0, 550, world_width, 170), Color(0.025, 0.06, 0.065, 0.34), true)
	for x in range(80, int(world_width), 310):
		draw_rect(Rect2(x,425,9,128), Color(0.22, 0.29, 0.29, 0.62), true)
		draw_rect(Rect2(x+72,440,92,72), Color(0.025, 0.045, 0.05, 0.68), true)
		draw_rect(Rect2(x+79,447,78,58), Color(0.20, 0.27, 0.27, 0.42), false, 2.0)
		draw_circle(Vector2(x+115,460), 4, Color(0.74*flicker,0.36*flicker,0.26*flicker,0.95))
		draw_line(Vector2(x+35,390), Vector2(x+35,443), Color(0.35,0.38,0.35,0.78), 5)
		draw_line(Vector2(x+32,395), Vector2(x+55,395), Color(0.35,0.38,0.35,0.78), 4)
		draw_rect(Rect2(x+165,400,72,7), Color(0.68,0.81,0.69,flicker))
	_draw_stage_architecture()
	draw_string(ThemeDB.fallback_font, Vector2(88,365), "PROJECT NULL  /  RESTRICTED", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c98d62"))
	draw_string(ThemeDB.fallback_font, Vector2(88,389), "CHETAVANI / WARNING / AUTHORIZED STAFF ONLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9b5a3"))
	if stage == 1:
		draw_string(ThemeDB.fallback_font, Vector2(170,455), "Q // SHIFT TO REVEAL THE NULL STAIRS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e88ba4"))
	draw_string(ThemeDB.fallback_font, Vector2(float(layout["shaft"])+20,198), "SECTOR %02d // %s" % [stage, RunState.level_name().to_upper()], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d0a878"))
	draw_string(ThemeDB.fallback_font, Vector2(world_width-600,390), "SUBJECT 0  /  CONTAINMENT STATUS: UNKNOWN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("a95d67"))
	for drop in rain:
		draw_line(drop, drop + Vector2(-4,13), Color(0.57,0.77,0.77,0.24), 1.0)

func _draw_stage_architecture() -> void:
	var accent := Color("74bcb3")
	match stage:
		1:
			_draw_stairwell(float(layout["shaft"]), 6)
		2:
			# Generator Hall: tall turbine housings and hanging conductors.
			for x in range(560, int(world_width) - 200, 790):
				draw_rect(Rect2(x,260,90,160), Color(0.025,0.055,0.06,0.72), true)
				draw_rect(Rect2(x+12,280,66,120), Color(0.08,0.21,0.21,0.58), false, 4)
				draw_circle(Vector2(x+45,340), 25, Color(0.20,0.76,0.68,0.32*flicker))
				draw_line(Vector2(x+45,180),Vector2(x+45,260),Color("607774"),4)
		3:
			# Flooded Records: rain-slick water line and archival shelving.
			draw_rect(Rect2(0,475,world_width,85), Color(0.06,0.30,0.32,0.24), true)
			for x in range(360, int(world_width), 580):
				draw_rect(Rect2(x,305,170,112), Color(0.025,0.05,0.055,0.7), true)
				for row in range(4):
					draw_rect(Rect2(x+10,316+row*23,150,4), Color(0.31,0.47,0.45,0.72), true)
					draw_rect(Rect2(x+22,324+row*23,42,12), Color(0.28,0.38,0.37,0.62), true)
			for x in range(120, int(world_width), 170):
				draw_line(Vector2(x,490+sin(float(x))*5),Vector2(x+62,490+sin(float(x))*5),Color(0.45,0.86,0.82,0.45),2)
		4:
			_draw_stairwell(float(layout["shaft"]), 10)
		5:
			# Null Ward: containment windows with intermittent warning lamps.
			for x in range(360, int(world_width), 520):
				draw_rect(Rect2(x,245,190,175), Color(0.025,0.035,0.045,0.78), true)
				draw_rect(Rect2(x+12,257,166,150), Color(0.18,0.035,0.065,0.45), false, 3)
				draw_line(Vector2(x+95,262),Vector2(x+95,403),Color(0.54,0.19,0.26,0.52),3)
				draw_circle(Vector2(x+166,272),5,Color(0.98,0.18,0.21,flicker))
		6:
			# Mirror Loop: repeated reflective panels that distort the familiar corridor.
			for x in range(320, int(world_width), 460):
				draw_rect(Rect2(x,220,120,195), Color(0.045,0.12,0.15,0.66), true)
				draw_rect(Rect2(x+8,228,104,177), Color(0.24,0.66,0.7,0.22), false, 3)
				draw_line(Vector2(x+16,397),Vector2(x+103,236),Color(0.58,0.90,0.88,0.48),2)
				draw_line(Vector2(x+16,236),Vector2(x+103,397),Color(0.58,0.90,0.88,0.22),2)
		7:
			# Project Null Core: large containment ring marks the final arena.
			var core := Vector2(float(layout["shaft"]),320)
			for radius in [145.0, 116.0, 84.0]:
				draw_arc(core, radius, 0, TAU, 96, Color(0.18,0.75,0.7,0.52*flicker), 5)
			draw_circle(core,28,Color(0.08,0.36,0.39,0.56*flicker))
			for angle in range(0,360,30):
				var ray := Vector2.RIGHT.rotated(deg_to_rad(float(angle)))
				draw_line(core+ray*150,core+ray*185,Color("c26e55"),4)
	if stage != 1 and stage != 4:
		draw_rect(Rect2(float(layout["shaft"])-2,245,4,175), accent, true)

func _draw_stairwell(shaft_x: float, rows: int) -> void:
	draw_rect(Rect2(shaft_x,215,370,330), Color(0.025,0.045,0.05,0.78), true)
	for row in range(rows):
		var inset := row * 18
		var y := 235 + row * 42
		draw_rect(Rect2(shaft_x+20+inset,y,330-inset*2,6), Color("7c6250"), true)
		draw_rect(Rect2(shaft_x+20+inset,y+4,5,38), Color("57483d"), true)
		draw_rect(Rect2(shaft_x+345-inset,y+4,5,38), Color("57483d"), true)
	draw_rect(Rect2(shaft_x+130,470,110,65), Color("080e11"), true)

func _build_level() -> void:
	var floor_color := Color(0.12,0.17,0.17,0.70)
	_platform(Vector2(world_width * 0.5,610), Vector2(world_width + 160.0,120), 2, floor_color)
	_build_routes("stable", 0, Color("55716b"))
	_build_routes("corrupt", 1, Color("9d4f68"))
	if stage == 1:
		_build_phase_objective_route()
	var fuse_points: Array = layout["fuses"]
	var relay_points: Array = layout["relays"]
	for i in range(3):
		var fuse_jitter := layout_rng.randf_range(-20.0, 20.0)
		var relay_jitter := layout_rng.randf_range(-20.0, 20.0)
		var fuse_position := Vector2(float(fuse_points[i]) + fuse_jitter, 500)
		var relay_position := Vector2(float(relay_points[i]) + relay_jitter, 500)
		var fuse_reality := RunState.REALITY_BOTH
		if stage == 1 and i == 0:
			# The first fuse and relay teach the player to climb across realities.
			fuse_position = Vector2(460, 275)
			relay_position = Vector2(600, 230)
			fuse_reality = RunState.REALITY_CORRUPTED
		_spawn_object("fuse", i, fuse_position, "FUSE %02d" % (i+1), "", fuse_reality)
		_spawn_object("relay", i, relay_position, "RELAY %02d" % (i+1))
	_spawn_object("checkpoint", 0, Vector2(float(layout["checkpoint"]),500), "CHECKPOINT")
	_spawn_object("record", 0, Vector2(float(layout["record"]),340), "PHASE CLUE // GLITCHED", "FIELD NOTE // RELAY PHASE KEY: STABLE > GLITCHED > STABLE // POWER STATE PERSISTS THROUGH A REALITY SHIFT.", RunState.REALITY_CORRUPTED)
	var hazard_list: Array = layout["hazards"]
	var hazard_count := mini(hazard_list.size(), 2 + stage)
	for i in range(hazard_count):
		var hazard_data: Array = hazard_list[i]
		var jitter := layout_rng.randf_range(-16.0, 16.0)
		_hazard(Vector2(float(hazard_data[0])+jitter,535), Vector2(float(hazard_data[2]),22.0), int(hazard_data[1]))
	_spawn_object("exit", 0, Vector2(world_width-100.0,500), "EMERGENCY EXIT")
	var enemy_points: Array = layout["enemies"]
	for i in range(enemy_points.size()):
		var enemy := ENEMY_SCENE.instantiate()
		var enemy_x := float(enemy_points[i]) + layout_rng.randf_range(-18.0,18.0)
		enemy.position = Vector2(enemy_x,505)
		add_child(enemy)
	add_child(HUD_SCENE.instantiate())
	if stage == 1:
		RunState.notice.emit("PHASE ROUTE AHEAD — Q REVEALS THE GLITCHED STAIRS TO FUSE 01")

func _build_phase_objective_route() -> void:
	# A short alternating-reality stair route makes Q necessary for the first
	# fuse. The Glitched steps rise from the floor to the fuse; the Stable
	# landing holds Relay 01, whose phase requirement is Stable.
	for point in [Vector2(260, 480), Vector2(360, 400), Vector2(460, 320)]:
		_platform(point, Vector2(112, 20), RunState.REALITY_CORRUPTED, Color("9d4f68"))
	_platform(Vector2(600, 280), Vector2(132, 20), RunState.REALITY_STABLE, Color("55716b"))

func _build_routes(key: String, mode: int, color: Color) -> void:
	var route: Array = layout[key]
	for point_data in route:
		var x := float(point_data[0]) + layout_rng.randf_range(-24.0,24.0)
		var y := float(point_data[1]) + layout_rng.randf_range(-9.0,9.0)
		var width := float(point_data[2]) + layout_rng.randf_range(-10.0,10.0)
		_platform(Vector2(x,y),Vector2(width,20.0),mode,color)

func _add_reality_light(point: Vector2) -> void:
	var gradient := Gradient.new()
	gradient.colors = [Color(1,1,1,0.48), Color(1,1,1,0)]
	var texture := GradientTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(1.0,0.5)
	texture.gradient = gradient
	var light := PointLight2D.new()
	light.position = point
	light.texture = texture
	light.texture_scale = 3.0
	light.color = Color("82bcb0")
	light.energy = 0.62
	add_child(light)

func _platform(point: Vector2, size: Vector2, mode: int, color: Color) -> void:
	var platform = PLATFORM_SCENE.instantiate()
	platform.position = point
	platform.rect_size = size
	platform.reality_mode = mode
	platform.tint = color
	add_child(platform)

func _hazard(point: Vector2, size: Vector2, mode: int) -> void:
	var hazard = HAZARD_SCENE.instantiate()
	hazard.position = point
	hazard.rect_size = size
	hazard.reality_mode = mode
	add_child(hazard)

func _spawn_object(kind: String, index: int, point: Vector2, title: String, record_text := "", object_reality := 2) -> void:
	var item = OBJECT_SCENE.instantiate()
	item.kind = kind
	item.objective_index = index
	item.label_text = record_text
	item.reality_mode = object_reality
	item.position = point
	item.set_meta("title", title)
	add_child(item)

func _on_reality_changed(mode: int) -> void:
	modulate = Color(1,1,1,1) if mode == RunState.REALITY_STABLE else Color(1.0,0.83,0.94,1)
