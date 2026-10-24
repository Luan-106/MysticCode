extends CharacterBody2D
class_name FacilityPlayer

signal health_changed(current: int, maximum: int)

const SPEED := 260.0
const JUMP_VELOCITY := -470.0
const COYOTE_TIME := 0.13
const JUMP_BUFFER := 0.14
const DASH_SPEED := 720.0
const DASH_TIME := 0.16
const DASH_COOLDOWN := 0.62
const WALL_JUMP_X := 340.0
const GRAVITY := 1250.0
const WALK_SHEET: Texture2D = preload("res://assets/player/player_walk_sheet.png")
const WALK_FRAME_SIZE := Vector2i(1024, 1536)
const WALK_FRAME_COUNT := 4

var facing := 1.0
var coyote := 0.0
var jump_buffer := 0.0
var dash_left := 0.0
var dash_cooldown := 0.0
var attack_cooldown := 0.0
var invulnerability := 0.0
var is_attacking := false
var attack_left := 0.0
var hit_ids: Dictionary = {}
var visual_time := 0.0
var visual_base_position := Vector2.ZERO
var visual_base_scale := Vector2.ONE

@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var slash: Polygon2D = $Slash
@onready var visual: AnimatedSprite2D = $Visual

func _ready() -> void:
    add_to_group("player")
    health_changed.emit(RunState.health, RunState.max_health)
    RunState.state_changed.connect(_on_run_state_changed)
    slash.visible = false
    visual.sprite_frames = _make_walk_frames()
    visual.play("idle")
    visual_base_position = visual.position
    visual_base_scale = visual.scale

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_Q:
                RunState.change_reality(_bounds())
            KEY_E:
                _interact()
            KEY_ESCAPE:
                get_tree().paused = not get_tree().paused
                RunState.notice.emit("PAUSED" if get_tree().paused else "")
            KEY_J:
                _attack()
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _attack()

func _physics_process(delta: float) -> void:
    coyote = COYOTE_TIME if is_on_floor() else maxf(0.0, coyote - delta)
    jump_buffer = maxf(0.0, jump_buffer - delta)
    dash_cooldown = maxf(0.0, dash_cooldown - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    invulnerability = maxf(0.0, invulnerability - delta)
    dash_left = maxf(0.0, dash_left - delta)
    attack_left = maxf(0.0, attack_left - delta)
    is_attacking = attack_left > 0.0
    slash.visible = is_attacking
    modulate.a = 0.4 if invulnerability > 0.0 and int(Time.get_ticks_msec() / 80) % 2 == 0 else 1.0

    var axis := Input.get_axis("move_left", "move_right")
    if absf(axis) > 0.1:
        facing = signf(axis)
        visual.scale.x = absf(visual_base_scale.x) * facing
        slash.scale.x = facing
    if Input.is_action_just_pressed("jump"):
        jump_buffer = JUMP_BUFFER
    if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
        dash_left = DASH_TIME
        dash_cooldown = DASH_COOLDOWN
        velocity.y = 0.0

    if dash_left > 0.0:
        velocity = Vector2(facing * DASH_SPEED, 0.0)
    else:
        if not is_on_floor():
            velocity.y += GRAVITY * delta
        velocity.x = move_toward(velocity.x, axis * SPEED, 1900.0 * delta)
        if is_on_wall() and velocity.y > 0.0 and absf(axis) > 0.1:
            velocity.y = minf(velocity.y, 175.0)
        if jump_buffer > 0.0 and coyote > 0.0:
            velocity.y = JUMP_VELOCITY
            jump_buffer = 0.0
            coyote = 0.0
        elif jump_buffer > 0.0 and is_on_wall():
            velocity = Vector2(-facing * WALL_JUMP_X, JUMP_VELOCITY * 0.92)
            facing *= -1.0
            jump_buffer = 0.0
        if Input.is_action_just_released("jump") and velocity.y < -100.0:
            velocity.y *= 0.48
    move_and_slide()
    _animate_visual(delta, axis)
    if global_position.y > 780.0:
        RunState.health = 1
        take_damage(1, Vector2.ZERO)
    if is_attacking and attack_left > 0.105:
        _hit_enemies()


func _animate_visual(delta: float, axis: float) -> void:
    visual_time += delta
    var bob := 0.0
    var sway := 0.0
    var lean := 0.0
    var squash := 1.0
    if dash_left > 0.0:
        bob = sin(visual_time * 38.0) * 1.2
        sway = -facing * 2.0
        lean = -facing * 0.14
        squash = 0.94
    elif not is_on_floor():
        bob = 1.5
        lean = -facing * 0.07
        squash = 1.035 if velocity.y < 0.0 else 0.96
    elif absf(velocity.x) > 28.0:
        if visual.animation != "walk":
            visual.play("walk")
        visual.speed_scale = clampf(absf(velocity.x) / SPEED, 0.75, 1.45)
        var run_speed := clampf(absf(velocity.x) / SPEED, 0.35, 1.35)
        var stride := visual_time * 17.0 * run_speed
        var step := sin(stride)
        bob = absf(step) * 4.2
        sway = sin(stride) * 2.0
        lean = clampf(velocity.x / SPEED, -1.0, 1.0) * 0.065 + cos(stride) * 0.018
        squash = 1.0 - absf(step) * 0.055
    else:
        if visual.animation != "idle":
            visual.play("idle")
        visual.speed_scale = 1.0
        bob = sin(visual_time * 2.2) * 1.6
        lean = sin(visual_time * 1.1) * 0.012
    if is_attacking:
        lean -= facing * 0.13
    visual.position = visual_base_position + Vector2(sway, -bob)
    visual.rotation = lean
    visual.scale.x = absf(visual_base_scale.x) * (1.0 + (1.0 - squash) * 0.35) * facing
    visual.scale.y = visual_base_scale.y * squash

func _make_walk_frames() -> SpriteFrames:
    var frames := SpriteFrames.new()
    frames.add_animation("idle")
    frames.set_animation_loop("idle", true)
    frames.add_frame("idle", _walk_atlas(0))
    frames.add_animation("walk")
    frames.set_animation_speed("walk", 9.0)
    frames.set_animation_loop("walk", true)
    for frame_index in WALK_FRAME_COUNT:
        frames.add_frame("walk", _walk_atlas(frame_index))
    return frames

func _walk_atlas(frame_index: int) -> AtlasTexture:
    var frame := AtlasTexture.new()
    frame.atlas = WALK_SHEET
    frame.region = Rect2(Vector2(frame_index * WALK_FRAME_SIZE.x, 0), WALK_FRAME_SIZE)
    return frame

func _attack() -> void:
    if attack_cooldown > 0.0:
        return
    attack_cooldown = 0.34
    attack_left = 0.20
    hit_ids.clear()
    _hit_enemies()

func _hit_enemies() -> void:
    var shape := RectangleShape2D.new()
    shape.size = Vector2(58, 42)
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0.0, global_position + Vector2(facing * 36.0, -5.0))
    query.collision_mask = 4
    query.exclude = [get_rid()]
    for hit in get_world_2d().direct_space_state.intersect_shape(query, 8):
        var target: Object = hit.collider
        if target.has_method("take_hit") and not hit_ids.has(target.get_instance_id()):
            hit_ids[target.get_instance_id()] = true
            target.call("take_hit", 1, facing)

func take_damage(amount: int, knockback: Vector2) -> void:
    if invulnerability > 0.0:
        return
    RunState.health = maxi(0, RunState.health - amount)
    health_changed.emit(RunState.health, RunState.max_health)
    velocity = knockback
    invulnerability = 1.1
    if RunState.health <= 0:
        global_position = RunState.checkpoint
        velocity = Vector2.ZERO
        RunState.player_died()
        health_changed.emit(RunState.health, RunState.max_health)

func _interact() -> void:
    var closest: Node2D = null
    var best := 90.0
    for node in get_tree().get_nodes_in_group("interactables"):
        var item := node as Node2D
        if not item or not item.visible:
            continue
        var distance := global_position.distance_to(item.global_position)
        if distance < best:
            best = distance
            closest = item
    if closest and closest.has_method("interact"):
        closest.call("interact", self)
    else:
        RunState.notice.emit("NOTHING WITHIN REACH")
func _bounds() -> Rect2:
    return Rect2(global_position - Vector2(15, 28), Vector2(30, 56))

func _on_run_state_changed() -> void:
    health_changed.emit(RunState.health, RunState.max_health)
