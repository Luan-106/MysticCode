extends CanvasLayer

signal finished

const COMIC_ATLAS: Texture2D = preload("res://assets/intro/between_two_realities_comic.png")
const RAIN_SCRIPT: Script = preload("res://scripts/ui/cinematic_rain.gd")
const TYPE_RATE := 48.0
const PAGE_SECONDS := 6.2
const GUTTER := 14.0

# Regions in the supplied 1536 x 1024 storyboard image.
const PANEL_REGIONS := [
	Rect2(0, 0, 578, 322),
	Rect2(580, 0, 448, 322),
	Rect2(1030, 0, 506, 322),
	Rect2(0, 324, 660, 328),
	Rect2(662, 324, 415, 328),
	Rect2(1079, 324, 457, 328),
	Rect2(0, 654, 550, 370),
	Rect2(552, 654, 408, 370),
	Rect2(962, 654, 287, 370),
	Rect2(1251, 654, 285, 370)
]

const PAGES := [
	{"panels": [0], "speaker": "PROJECT NULL // RESTRICTED ARCHIVE", "text": "1998. Beneath an abandoned hill station in India's Western Ghats, a secret government facility tried to build a bridge between realities.", "sfx": "ARCHIVE OPEN"},
	{"panels": [1, 2], "speaker": "DR. VORA // FINAL TAPE", "text": "When the instruments failed, the researchers turned to an ancient forbidden manuscript. Technology, ritual symbols, a chant—and something answered.", "sfx": "THOOM"},
	{"panels": [3], "speaker": "NULL EVENT // REALITY FRACTURE", "text": "Reality tore in two. Stable and Glitched worlds began to overlap. Shadows disobeyed their owners. Time stopped behaving like time.", "sfx": "KRRSH"},
	{"panels": [4, 5], "speaker": "ARCHIVE // SUBJECT 0", "text": "Subject 0 was the first human used in the binding ritual. Neither alive nor dead, it remains caught between both worlds. The incident was buried.", "sfx": "CLASSIFIED"},
	{"panels": [6, 7], "speaker": "YOU // RECOVERED MEMORY", "text": "Years later, you enter the abandoned facility searching for someone connected to the incident. Three relays still pulse below—anchors in the prison.", "sfx": "THREE ANCHORS"},
	{"panels": [8, 9], "speaker": "UNKNOWN // THROUGH THE WALL", "text": "Something is watching. The symbols change when you look away. The ritual is beginning again—and this time, it may have chosen you.", "sfx": "DON'T LOOK BACK"}
]

var ui: Control
var comic_stage: Control
var caption_panel: PanelContainer
var speaker_label: Label
var dialogue_label: Label
var page_label: Label
var prompt_label: Label
var sound_effect: Label
var flash: ColorRect
var index := 0
var beat_clock := 0.0
var active := true
var title_card := false
var glitch_clock := 0.0
var page_tween: Tween

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_show_page(0)

func _build_ui() -> void:
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)

	var base := ColorRect.new()
	base.color = Color(0.012, 0.018, 0.022, 1.0)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(base)

	var rain := Control.new()
	rain.set_script(RAIN_SCRIPT)
	rain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(rain)

	var header := _label("WESTERN GHATS  /  1998     •     RESTRICTED ARCHIVE", 15, Color("c99567"))
	header.anchor_left = 0.045
	header.anchor_right = 0.78
	header.anchor_top = 0.025
	header.anchor_bottom = 0.075
	ui.add_child(header)

	page_label = _label("", 14, Color("70cbc3"))
	page_label.anchor_left = 0.76
	page_label.anchor_right = 0.955
	page_label.anchor_top = 0.025
	page_label.anchor_bottom = 0.075
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.add_child(page_label)

	comic_stage = Control.new()
	comic_stage.anchor_left = 0.035
	comic_stage.anchor_right = 0.965
	comic_stage.anchor_top = 0.09
	comic_stage.anchor_bottom = 0.625
	comic_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(comic_stage)

	caption_panel = PanelContainer.new()
	caption_panel.anchor_left = 0.045
	caption_panel.anchor_right = 0.955
	caption_panel.anchor_top = 0.66
	caption_panel.anchor_bottom = 0.91
	caption_panel.add_theme_stylebox_override("panel", _caption_style())
	ui.add_child(caption_panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	caption_panel.add_child(stack)
	speaker_label = _label("", 15, Color("efa85b"))
	speaker_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(speaker_label)
	dialogue_label = _label("", 23, Color("e5e8e3"))
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(dialogue_label)

	var footer := _label("SHIFT REALITIES   /   RESTORE THREE RELAYS   /   FIND THE TRUTH", 12, Color("bd715f"))
	footer.anchor_left = 0.045
	footer.anchor_right = 0.60
	footer.anchor_top = 0.93
	footer.anchor_bottom = 0.98
	ui.add_child(footer)

	prompt_label = _label("ENTER / SPACE / CLICK  CONTINUE      •      ESC  SKIP", 14, Color("d4d1c5"))
	prompt_label.anchor_left = 0.56
	prompt_label.anchor_right = 0.955
	prompt_label.anchor_top = 0.93
	prompt_label.anchor_bottom = 0.98
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.add_child(prompt_label)

	sound_effect = _label("", 28, Color("ff454d"))
	sound_effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sound_effect.add_theme_color_override("font_shadow_color", Color(0.03, 0.02, 0.02, 0.9))
	sound_effect.add_theme_constant_override("shadow_offset_x", 3)
	sound_effect.add_theme_constant_override("shadow_offset_y", 3)
	sound_effect.anchor_left = 0.62
	sound_effect.anchor_right = 0.95
	sound_effect.anchor_top = 0.54
	sound_effect.anchor_bottom = 0.63
	ui.add_child(sound_effect)

	flash = ColorRect.new()
	flash.color = Color(0.95, 0.12, 0.22, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(flash)

func _process(delta: float) -> void:
	if not active:
		return
	beat_clock += delta
	glitch_clock += delta
	if not title_card:
		dialogue_label.visible_characters = mini(dialogue_label.text.length(), int(beat_clock * TYPE_RATE))
		if beat_clock >= PAGE_SECONDS:
			_advance()
	if glitch_clock > randf_range(2.0, 4.3):
		glitch_clock = 0.0
		_glitch_flash()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_finish()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_KP_ENTER]:
			_advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		get_viewport().set_input_as_handled()

func _show_page(new_index: int) -> void:
	index = new_index
	beat_clock = 0.0
	for child in comic_stage.get_children():
		child.queue_free()
	var page: Dictionary = PAGES[index]
	speaker_label.text = str(page["speaker"])
	dialogue_label.text = str(page["text"])
	dialogue_label.visible_characters = 0
	page_label.text = "RECOVERED PANELS     //     %02d  /  %02d" % [index + 1, PAGES.size()]
	sound_effect.text = str(page["sfx"])
	sound_effect.rotation_degrees = randf_range(-5.0, 5.0)
	_layout_panels(page["panels"])
	_play_impact()

func _layout_panels(panel_ids: Array) -> void:
	if page_tween != null and page_tween.is_running():
		page_tween.kill()
	var stage_size := comic_stage.size
	if stage_size.x < 1.0 or stage_size.y < 1.0:
		stage_size = get_viewport().get_visible_rect().size * Vector2(0.93, 0.535)
	var count := panel_ids.size()
	var gap := GUTTER if count > 1 else 0.0
	var max_width := stage_size.x if count > 1 else stage_size.x * 0.82
	var card_width := (max_width - gap) / float(count)
	page_tween = create_tween()
	page_tween.set_parallel(true)
	for i in range(count):
		var panel_id := int(panel_ids[i])
		var region: Rect2 = PANEL_REGIONS[panel_id]
		var texture := AtlasTexture.new()
		texture.atlas = COMIC_ATLAS
		texture.region = region
		var aspect := region.size.x / region.size.y
		var width := card_width
		var height := width / aspect
		if height > stage_size.y:
			height = stage_size.y
			width = height * aspect
		var frame := PanelContainer.new()
		frame.add_theme_stylebox_override("panel", _comic_frame_style())
		frame.size = Vector2(width, height)
		frame.position = Vector2((stage_size.x - (float(count) * width + gap * float(count - 1))) * 0.5 + float(i) * (width + gap), (stage_size.y - height) * 0.5)
		frame.pivot_offset = frame.size * 0.5
		frame.modulate.a = 0.0
		frame.scale = Vector2(0.91, 0.91)
		comic_stage.add_child(frame)
		var image := TextureRect.new()
		image.texture = texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		image.size_flags_vertical = Control.SIZE_EXPAND_FILL
		image.custom_minimum_size = Vector2(width, height)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(image)
		var delay := 0.08 + float(i) * 0.16
		page_tween.tween_property(frame, "modulate:a", 1.0, 0.34).set_delay(delay)
		page_tween.tween_property(frame, "scale", Vector2.ONE, 0.42).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		page_tween.tween_property(frame, "rotation_degrees", randf_range(-0.8, 0.8), 0.34).set_delay(delay)

func _advance() -> void:
	if title_card:
		_finish()
	elif dialogue_label.visible_characters < dialogue_label.text.length():
		dialogue_label.visible_characters = -1
		beat_clock = PAGE_SECONDS - 0.9
	elif index + 1 < PAGES.size():
		_show_page(index + 1)
	else:
		_show_title_card()

func _show_title_card() -> void:
	if page_tween != null and page_tween.is_running():
		page_tween.kill()
	title_card = true
	beat_clock = 0.0
	page_label.text = "PROJECT NULL     //     CONTAINMENT FAILURE"
	speaker_label.text = "THE FORGOTTEN FACILITY"
	dialogue_label.text = "Three relays keep the barrier sealed. Shift between realities, restore the anchors, and uncover who—or what—called you here."
	dialogue_label.visible_characters = -1
	sound_effect.text = "DON'T LOOK BACK"
	prompt_label.text = "ENTER / SPACE / CLICK  BEGIN DESCENT      •      ESC  BEGIN NOW"
	for child in comic_stage.get_children():
		child.queue_free()
	var title_region: Rect2 = PANEL_REGIONS[0]
	var art := TextureRect.new()
	var texture := AtlasTexture.new()
	texture.atlas = COMIC_ATLAS
	texture.region = title_region
	art.texture = texture
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.anchor_left = 0.05
	art.anchor_right = 0.95
	art.anchor_top = 0.0
	art.anchor_bottom = 1.0
	art.modulate.a = 0.0
	comic_stage.add_child(art)
	var tween := create_tween()
	tween.tween_property(art, "modulate:a", 1.0, 0.7)
	_play_impact()

func _finish() -> void:
	if not active:
		return
	active = false
	finished.emit()
	queue_free()

func _play_impact() -> void:
	flash.color = Color(0.82, 0.12, 0.2, 0.22)
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.32)
	sound_effect.scale = Vector2(1.28, 1.28)
	var sfx_tween := create_tween()
	sfx_tween.tween_property(sound_effect, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _glitch_flash() -> void:
	flash.color = Color(0.05, 0.62, 0.68, 0.075)
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.16)

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _comic_frame_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0c1011")
	style.border_color = Color("c8bda6")
	style.set_border_width_all(3)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func _caption_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.025, 0.03, 0.94)
	style.border_color = Color(0.48, 0.68, 0.62, 0.78)
	style.set_border_width_all(2)
	style.set_corner_radius_all(2)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style
