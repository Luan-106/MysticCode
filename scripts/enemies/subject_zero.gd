extends CharacterBody2D
class_name SubjectZero

const WALK_SPEED := 115.0
const CHASE_SPEED := 205.0
const GRAVITY := 1250.0
const WALK_SHEET: Texture2D = preload("res://assets/enemies/subject_zero_walk_sheet.png")
const WALK_FRAME_SIZE := Vector2i(973, 1616)
const WALK_FRAME_COUNT := 4
@export var vision_range := 470.0
@export var attack_range := 62.0
@export var attack_windup := 0.38
@export var attack_damage := 1
@export var shift_disruption_time := 0.32
var health := 4
var target: Node2D
var patrol_origin := 0.0
var direction := -1.0
var state := "PATROL"
var attack_cooldown := 0.0
var recovery := 0.0
var windup := 0.0
var disrupted := 0.0
var hurt_flash := 0.0
var visual_clock := 0.0
var visual_base_position := Vector2.ZERO
var visual_base_scale := Vector2.ONE
var active_visual: Node2D
var attack_indicator: Polygon2D
@onready var walk_visual: AnimatedSprite2D = $Visual

func _ready() -> void:
	add_to_group("subject_zero")
	patrol_origin = global_position.x
	target = get_tree().get_first_node_in_group("player") as Node2D
	walk_visual.sprite_frames = _make_walk_frames()
	walk_visual.play("idle")
	$Visual.visible = true
	$CrouchedVisual.visible = false
	active_visual = walk_visual
	visual_base_position = active_visual.position
	visual_base_scale = active_visual.scale
	visual_clock = randf() * TAU
	attack_indicator = Polygon2D.new()
	attack_indicator.name = "AttackTell"
	attack_indicator.polygon = PackedVector2Array([Vector2(0, -15), Vector2(76, -31), Vector2(82, 0), Vector2(76, 31), Vector2(0, 15)])
	attack_indicator.color = Color(1.0, 0.18, 0.28, 0.28)
	attack_indicator.visible = false
	attack_indicator.z_index = -1
	add_child(attack_indicator)
	RunState.reality_changed.connect(_on_reality_changed)

func _physics_process(delta: float) -> void:
	if not target:
		target = get_tree().get_first_node_in_group("player") as Node2D
		return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	recovery = maxf(0.0, recovery - delta)
	windup = maxf(0.0, windup - delta)
	disrupted = maxf(0.0, disrupted - delta)
	hurt_flash = maxf(0.0, hurt_flash - delta)
	var visual_tint: Color = Color("ff6672") if hurt_flash > 0.0 else Color.WHITE
	$Visual.modulate = visual_tint
	$CrouchedVisual.modulate = visual_tint
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	var distance := global_position.distance_to(target.global_position)
	var in_glitched := RunState.reality == RunState.REALITY_CORRUPTED
	var detection_range := vision_range + (RunState.current_level * 22.0) if in_glitched else vision_range * 0.62
	attack_indicator.visible = windup > 0.0
	attack_indicator.scale.x = direction
	if disrupted > 0.0:
		state = "DISRUPTED"
		windup = 0.0
		velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
	elif windup > 0.0 or state == "TELEGRAPH":
		state = "TELEGRAPH"
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
		if windup <= 0.0:
			attack_indicator.visible = false
			if global_position.distance_to(target.global_position) <= attack_range + 8.0:
				state = "ATTACK"
				attack_cooldown = 1.05
				recovery = 0.50
				if target.has_method("take_damage"):
					var knock := Vector2(signf(target.global_position.x - global_position.x) * 300.0, -220.0)
					target.call("take_damage", attack_damage, knock)
			else:
				state = "RECOVERY"
				recovery = 0.18
	elif recovery > 0.0:
		state = "RECOVERY"
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	elif distance < detection_range:
		if distance < attack_range and attack_cooldown <= 0.0:
			state = "TELEGRAPH"
			windup = attack_windup
			attack_indicator.visible = true
			RunState.notice.emit("SUBJECT 0 WINDING UP — MOVE OR DASH")
		else:
			state = "CHASE"
			direction = signf(target.global_position.x - global_position.x)
			var phase_speed := 1.0 if in_glitched else 0.68
			velocity.x = direction * (CHASE_SPEED + (RunState.current_level - 1) * 14.0 + (70.0 if RunState.relays >= 3 else 0.0)) * phase_speed
	else:
		state = "PATROL"
		if absf(global_position.x - patrol_origin) > 190.0:
			direction *= -1.0
			patrol_origin = global_position.x
		velocity.x = direction * (WALK_SPEED + (RunState.current_level - 1) * 8.0)
	move_and_slide()
	_animate_visual(delta)

func take_hit(damage: int, knock_direction: float) -> void:
	health -= damage
	hurt_flash = 0.18
	velocity = Vector2(knock_direction * 240.0, -100.0)
	if health <= 0:
		queue_free()
		RunState.notice.emit("SUBJECT 0 LOST IN THE STATIC")

func _on_reality_changed(_mode: int) -> void:
	# A shift briefly scrambles tracking and cancels a telegraphed strike.
	# The enemy can reacquire the player after the disruption ends.
	disrupted = shift_disruption_time
	windup = 0.0
	attack_indicator.visible = false

func _animate_visual(delta: float) -> void:
	visual_clock += delta
	if state == "PATROL" or state == "CHASE":
		if walk_visual.animation != "walk":
			walk_visual.play("walk")
		walk_visual.speed_scale = 1.0 if state == "PATROL" else 1.35
	else:
		if walk_visual.animation != "idle":
			walk_visual.play("idle")
		walk_visual.speed_scale = 1.0
	var bob := 0.0
	var sway := 0.0
	var lean := 0.0
	var squash := 1.0
	if state == "CHASE":
		var stride := visual_clock * 14.0
		var step := sin(stride)
		bob = absf(step) * 5.0
		sway = step * 2.4
		lean = -direction * 0.11 + cos(stride) * 0.035
		squash = 1.0 - absf(step) * 0.045
	elif state == "PATROL":
		var stride := visual_clock * 8.0
		var step := sin(stride)
		bob = absf(step) * 3.0
		sway = step * 1.6
		lean = -direction * 0.045 + cos(stride) * 0.02
		squash = 1.0 - absf(step) * 0.025
	elif state == "ATTACK":
		bob = sin(visual_clock * 20.0) * 2.0
		lean = -direction * 0.18
		squash = 0.96
	elif state == "RECOVERY":
		bob = sin(visual_clock * 11.0) * 1.5
		lean = direction * 0.08
	else:
		bob = sin(visual_clock * 2.0) * 1.4
	active_visual.position = visual_base_position + Vector2(sway, -bob)
	active_visual.rotation = lean
	active_visual.scale.x = absf(visual_base_scale.x) * (1.0 + (1.0 - squash) * 0.3) * -direction
	active_visual.scale.y = visual_base_scale.y * squash

func _make_walk_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.add_frame("idle", _walk_atlas(0))
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 7.5)
	frames.set_animation_loop("walk", true)
	for frame_index in WALK_FRAME_COUNT:
		frames.add_frame("walk", _walk_atlas(frame_index))
	return frames

func _walk_atlas(frame_index: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = WALK_SHEET
	frame.region = Rect2(Vector2(frame_index * WALK_FRAME_SIZE.x, 0), WALK_FRAME_SIZE)
	return frame
