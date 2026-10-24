extends Node

signal state_changed
signal reality_changed(mode: int)
signal reality_shift_started(next_mode: int)
signal notice(text: String)
signal escaped
signal death_reset

enum Reality { STABLE, CORRUPTED, BOTH }
const REALITY_STABLE := Reality.STABLE
const REALITY_CORRUPTED := Reality.CORRUPTED
const REALITY_BOTH := Reality.BOTH
const REALITY_SHIFT_COOLDOWN := 0.6
const REALITY_SHIFT_TRANSITION := 0.28
const RELAY_REALITY_SEQUENCE := [Reality.STABLE, Reality.CORRUPTED, Reality.STABLE]
const LEVEL_COUNT := 7
const LEVEL_NAMES := [
    "The Forgotten Facility",
    "Generator Hall",
    "Flooded Records",
    "The Stepwell Descent",
    "Null Ward",
    "Mirror Loop",
    "Project Null Core"
]

var current_level := 1
var intro_seen := false
var reality := Reality.STABLE
var fuses := 0
var relays := 0
var health := 5
var max_health := 5
var checkpoint := Vector2(120, 500)
var gate_open := false
var run_seed := 0
var shift_cooldown_remaining := 0.0
var shift_transition_remaining := 0.0
var shift_locked := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    if run_seed == 0:
        run_seed = _new_run_seed()

func _process(delta: float) -> void:
    if shift_cooldown_remaining > 0.0:
        shift_cooldown_remaining = maxf(0.0, shift_cooldown_remaining - delta)
    if shift_transition_remaining > 0.0:
        shift_transition_remaining = maxf(0.0, shift_transition_remaining - delta)
        if shift_transition_remaining <= 0.0:
            shift_locked = false

func _new_run_seed() -> int:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    return rng.randi()

func reset_run() -> void:
    run_seed = _new_run_seed()
    current_level = 1
    intro_seen = false
    _reset_level_state()
    state_changed.emit()

func begin_level() -> void:
    _reset_level_state()
    state_changed.emit()
    notice.emit("LEVEL %d / %d  |  %s" % [current_level, LEVEL_COUNT, level_name()])

func _reset_level_state() -> void:
    reality = Reality.STABLE
    fuses = 0
    relays = 0
    health = max_health
    checkpoint = Vector2(120, 500)
    gate_open = false
    shift_cooldown_remaining = 0.0
    shift_transition_remaining = 0.0
    shift_locked = false

func level_name() -> String:
    return LEVEL_NAMES[clampi(current_level - 1, 0, LEVEL_NAMES.size() - 1)]

func reality_name(mode: int = -1) -> String:
    var selected := reality if mode < 0 else mode
    return "STABLE" if selected == Reality.STABLE else "GLITCHED"

func advance_level() -> void:
    if current_level >= LEVEL_COUNT:
        win()
        return
    current_level += 1
    _reset_level_state()
    state_changed.emit()
    get_tree().call_deferred("reload_current_scene")

func collect_fuse() -> void:
    fuses = mini(3, fuses + 1)
    notice.emit("FUSE RECOVERED  |  %d / 3" % fuses)
    state_changed.emit()

func activate_relay(relay_index: int) -> bool:
    if relays >= 3:
        notice.emit("ALL RELAYS ARE ONLINE")
        return false
    if relay_index != relays:
        notice.emit("POWER ROUTE: RESTORE RELAY %d NEXT" % (relays + 1))
        return false
    if fuses <= relays:
        notice.emit("RELAY %d: INSERT A RECOVERED FUSE" % (relay_index + 1))
        return false
    var required_reality: int = RELAY_REALITY_SEQUENCE[relay_index]
    if reality != required_reality:
        notice.emit("RELAY %d OUT OF PHASE — SWITCH TO %s" % [relay_index + 1, reality_name(required_reality)])
        return false
    relays += 1
    notice.emit("RELAY %d RESTORED IN %s" % [relays, reality_name()])
    if relays == 3:
        gate_open = true
        notice.emit("EXIT POWER RESTORED — REACH THE EMERGENCY EXIT. SUBJECT 0 IS MOVING.")
    state_changed.emit()
    return true

func set_checkpoint(point: Vector2) -> void:
    checkpoint = point
    notice.emit("CHECKPOINT RECORDED")

func change_reality(player_bounds: Rect2) -> bool:
    if shift_locked:
        notice.emit("REALITY SHIFT IS STILL SETTLING")
        return false
    if shift_cooldown_remaining > 0.0:
        notice.emit("REALITY SHIFT RECHARGING — %0.1f SECONDS" % shift_cooldown_remaining)
        return false
    var next: int = Reality.CORRUPTED if reality == Reality.STABLE else Reality.STABLE
    for platform in get_tree().get_nodes_in_group("reality_platforms"):
        if not is_instance_valid(platform) or int(platform.get("reality_mode")) != next:
            continue
        if platform.has_method("world_bounds") and player_bounds.intersects(platform.call("world_bounds")):
            notice.emit("SHIFT BLOCKED: MOVE CLEAR OF THE MATERIALIZING PLATFORM")
            return false
    shift_locked = true
    shift_transition_remaining = REALITY_SHIFT_TRANSITION
    shift_cooldown_remaining = REALITY_SHIFT_COOLDOWN
    reality_shift_started.emit(next)
    reality = next
    for object in get_tree().get_nodes_in_group("reality_object"):
        if not is_instance_valid(object) or not object.has_method("set_reality_active"):
            continue
        var object_mode: int = int(object.get("reality_mode"))
        object.call("set_reality_active", object_mode == reality or object_mode == Reality.BOTH)
    reality_changed.emit(reality)
    notice.emit("REALITY SHIFT: %s" % reality_name())
    state_changed.emit()
    return true

func player_died() -> void:
    run_seed = _new_run_seed()
    current_level = 1
    _reset_level_state()
    state_changed.emit()
    notice.emit("RUN LOST — RETURNING TO LEVEL 1")
    death_reset.emit()

func win() -> void:
    escaped.emit()
