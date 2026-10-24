extends CanvasLayer
var stage_label: Label
var health_label: Label
var objective_label: Label
var reality_label: Label
var shift_label: Label
var shift_cooldown_bar: ProgressBar
var shift_flash: ColorRect
var message_label: Label
var prompt_label: Label
var shade: ColorRect
var modal_title: Label
var modal_body: Label
var modal_buttons: HBoxContainer
var modal: PanelContainer
var modal_kind := ""
var escape_guard := false
var message_time := 0.0
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_ui()
    RunState.state_changed.connect(_refresh)
    RunState.reality_changed.connect(_on_reality)
    RunState.reality_shift_started.connect(_on_reality_shift_started)
    RunState.notice.connect(_on_notice)
    RunState.escaped.connect(_on_win)
    RunState.death_reset.connect(_on_death)
    _refresh()
    message_label.text = "LEVEL %d / 7  •  %s  •  WESTERN GHATS, 1998" % [RunState.current_level, RunState.level_name().to_upper()]
    message_time = 8.0
func _build_ui() -> void:
    var hud := Control.new()
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hud)
    var vignette := TextureRect.new()
    vignette.name = "AtmosphereVignette"
    vignette.texture = _make_vignette()
    vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    vignette.stretch_mode = TextureRect.STRETCH_SCALE
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(vignette)
    var panel := PanelContainer.new()
    panel.position = Vector2(24, 22)
    panel.custom_minimum_size = Vector2(435, 180)
    panel.size = Vector2(435, 180)
    hud.add_child(panel)
    panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025,0.055,0.065,0.9)))
    var stack := VBoxContainer.new()
    panel.add_child(stack)
    stage_label = _label("LEVEL 1 / 7  •  THE FORGOTTEN FACILITY", 15, Color("e9a64c"))
    health_label = _label("HEALTH  ♥ ♥ ♥ ♥ ♥", 20, Color("e9d7c0"))
    objective_label = _label("FUSES 0/3    RELAYS 0/3", 17, Color("6fe0d0"))
    reality_label = _label("REALITY: STABLE  [Q]", 16, Color("8cded4"))
    stack.add_child(stage_label)
    stack.add_child(health_label)
    stack.add_child(objective_label)
    stack.add_child(reality_label)
    shift_label = _label("SHIFT READY  •  0.6s RECHARGE", 13, Color("b5d7ce"))
    stack.add_child(shift_label)
    shift_cooldown_bar = ProgressBar.new()
    shift_cooldown_bar.custom_minimum_size = Vector2(280, 8)
    shift_cooldown_bar.max_value = RunState.REALITY_SHIFT_COOLDOWN
    shift_cooldown_bar.value = 0.0
    shift_cooldown_bar.show_percentage = false
    stack.add_child(shift_cooldown_bar)
    shift_flash = ColorRect.new()
    shift_flash.color = Color(0.28, 0.95, 0.87, 0.0)
    shift_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    shift_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(shift_flash)
    prompt_label = _label("A/D MOVE   SPACE JUMP   SHIFT DASH   J / CLICK ATTACK   E INTERACT", 15, Color("d6d3c9"))
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    prompt_label.offset_left = 30
    prompt_label.offset_right = -30
    prompt_label.offset_top = -45
    prompt_label.offset_bottom = -15
    hud.add_child(prompt_label)
    message_label = _label("", 17, Color("ffcb83"))
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    message_label.offset_top = 25
    message_label.offset_bottom = 55
    hud.add_child(message_label)
    shade = ColorRect.new()
    shade.color = Color(0.015,0.025,0.03,0.86)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.visible = false
    add_child(shade)
    modal = PanelContainer.new()
    modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    modal.position = Vector2(-250,-150)
    modal.size = Vector2(500,300)
    modal.custom_minimum_size = Vector2(500,300)
    modal.visible = false
    modal.add_theme_stylebox_override("panel", _panel_style(Color(0.035,0.055,0.065,0.98)))
    add_child(modal)
    var box := VBoxContainer.new()
    modal.add_child(box)
    modal_title = _label("", 34, Color("e5b374"))
    modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body = _label("", 18, Color("d5d5ce"))
    modal_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(modal_title)
    box.add_child(modal_body)
    modal_buttons = HBoxContainer.new()
    modal_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_child(modal_buttons)
    _add_button("RESUME", _resume)
    _add_button("RESTART RUN", _restart)
    _add_button("QUIT", _quit)
func _process(delta: float) -> void:
    _update_interaction_prompt()
    if shift_cooldown_bar:
        shift_cooldown_bar.value = RunState.shift_cooldown_remaining
        shift_label.text = "SHIFT READY  •  Q" if RunState.shift_cooldown_remaining <= 0.0 else "SHIFT RECHARGING  •  %0.1fs" % RunState.shift_cooldown_remaining
    if message_time > 0.0:
        message_time -= delta
        if message_time <= 0.0 and modal_kind == "":
            message_label.text = ""
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and get_tree().paused and modal_kind == "pause" and not escape_guard:
        _resume()
func _refresh() -> void:
    if not health_label: return
    var hearts := ""
    for i in range(RunState.max_health): hearts += "♥ " if i < RunState.health else "♡ "
    stage_label.text = "LEVEL %d / %d  •  %s" % [RunState.current_level, RunState.LEVEL_COUNT, RunState.level_name().to_upper()]
    health_label.text = "HEALTH  " + hearts.strip_edges()
    objective_label.text = "FUSES  %d / 3      RELAYS  %d / 3" % [RunState.fuses, RunState.relays]
    reality_label.text = "REALITY: %s   [Q]" % ("STABLE" if RunState.reality == RunState.REALITY_STABLE else "GLITCHED")
func _update_interaction_prompt() -> void:
    var player := get_tree().get_first_node_in_group("player") as Node2D
    if not player: return
    var nearest: Node2D = null
    var nearest_distance := 90.0
    for node in get_tree().get_nodes_in_group("interactables"):
        var item_2d := node as Node2D
        if not item_2d or not item_2d.visible: continue
        var distance: float = player.global_position.distance_to(item_2d.global_position)
        if distance < nearest_distance:
            nearest = item_2d
            nearest_distance = distance
    if nearest:
        prompt_label.text = "E  INTERACT  •  " + str(nearest.get_meta("title", "FACILITY OBJECT"))
    else:
        prompt_label.text = "A/D MOVE   SPACE JUMP   SHIFT DASH   J / CLICK ATTACK   Q REALITY   ESC PAUSE"
func _on_reality(mode: int) -> void:
    reality_label.text = "REALITY: %s   [Q]" % ("STABLE" if mode == RunState.REALITY_STABLE else "GLITCHED")
    reality_label.add_theme_color_override("font_color", Color("8cded4") if mode == RunState.REALITY_STABLE else Color("e77b91"))
func _on_reality_shift_started(next_mode: int) -> void:
    if not shift_flash:
        return
    shift_flash.color = Color(0.22, 0.94, 0.85, 0.24) if next_mode == RunState.REALITY_STABLE else Color(0.96, 0.20, 0.42, 0.24)
    var tween := create_tween()
    tween.tween_property(shift_flash, "color:a", 0.0, RunState.REALITY_SHIFT_TRANSITION)

func _on_notice(text: String) -> void:
    if text.is_empty():
        if modal_kind == "pause": _hide_modal()
        return
    if text == "PAUSED":
        escape_guard = true
        get_tree().create_timer(0.2, true).timeout.connect(func(): escape_guard = false)
        _show_modal("PAUSED", "The corridor is quiet. Subject 0 is still out there.", "pause")
        return
    message_label.text = text
    message_time = 3.2
func _on_death() -> void:
    get_tree().paused = true
    _show_modal("RUN LOST", "The run resets to Level 1. Fuses and relays must be recovered again.", "death")
    get_tree().create_timer(1.4, true).timeout.connect(func():
        if modal_kind == "death":
            get_tree().paused = false
            _hide_modal()
            get_tree().reload_current_scene()
    )
func _on_win() -> void:
    get_tree().paused = true
    _show_modal("ESCAPED", "The rain swallows the alarm. Subject 0 remains somewhere below.\n\nWhy did it recognize you?", "win")
    modal_buttons.get_child(0).queue_free()
func _show_modal(title: String, body: String, kind: String) -> void:
    modal_kind = kind
    modal_title.text = title
    modal_body.text = body
    shade.visible = true
    modal.visible = true
func _hide_modal() -> void:
    modal_kind = ""
    shade.visible = false
    modal.visible = false
func _resume() -> void:
    get_tree().paused = false
    _hide_modal()
func _restart() -> void:
    get_tree().paused = false
    RunState.reset_run()
    get_tree().reload_current_scene()
func _quit() -> void:
    get_tree().quit()
func _add_button(text: String, action: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(135,46)
    button.pressed.connect(action)
    modal_buttons.add_child(button)
func _label(text: String, size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    return label
func _panel_style(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = Color("53736f")
    style.set_border_width_all(1)
    style.set_corner_radius_all(6)
    style.content_margin_left = 15
    style.content_margin_right = 15
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    return style
















func _make_vignette() -> Texture2D:
    var gradient := Gradient.new()
    gradient.colors = [Color(0.005, 0.014, 0.02, 0.0), Color(0.005, 0.012, 0.018, 0.40)]
    var texture := GradientTexture2D.new()
    texture.width = 256
    texture.height = 256
    texture.fill = GradientTexture2D.FILL_RADIAL
    texture.fill_from = Vector2(0.5, 0.5)
    texture.fill_to = Vector2(1.0, 0.5)
    texture.gradient = gradient
    return texture
