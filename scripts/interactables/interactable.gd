extends Node2D

@export_enum("fuse", "relay", "checkpoint", "exit", "record") var kind := "fuse"
@export_enum("Stable", "Glitched", "Both") var reality_mode := 2
@export var objective_index := 0
@export var label_text := ""
var used := false
var icon_clock := 0.0

@onready var icon: Polygon2D = $Icon
@onready var fuse_art: Sprite2D = $FuseArt
@onready var relay_art: Sprite2D = $RelayArt

func _ready() -> void:
    add_to_group("interactables")
    add_to_group("reality_object")
    if reality_mode == RunState.REALITY_STABLE:
        add_to_group("reality_stable")
    elif reality_mode == RunState.REALITY_CORRUPTED:
        add_to_group("reality_corrupted")
    fuse_art.visible = kind == "fuse"
    relay_art.visible = kind == "relay"
    icon.visible = kind != "fuse" and kind != "relay"
    if kind == "fuse":
        icon.color = Color("e9a64c")
    elif kind == "relay":
        icon.color = Color("57d6ca")
    elif kind == "checkpoint":
        icon.color = Color("e05746")
    else:
        icon.color = Color("d9d6c9")
    set_reality_active(reality_mode == RunState.reality or reality_mode == RunState.REALITY_BOTH)

func set_reality_active(active: bool) -> void:
    visible = active

func _process(delta: float) -> void:
    icon_clock += delta
    if fuse_art.visible:
        fuse_art.scale = Vector2.ONE * (0.42 + sin(icon_clock * 2.2) * 0.006)
    if relay_art.visible and not used:
        relay_art.scale = Vector2.ONE * (0.42 + sin(icon_clock * 1.8) * 0.004)
    if kind != "exit" or used or not RunState.gate_open:
        return
    var player := get_tree().get_first_node_in_group("player") as Node2D
    if player and global_position.distance_to(player.global_position) <= 68.0:
        used = true
        RunState.advance_level()

func interact(_player: Node) -> void:
    match kind:
        "fuse":
            if used: return
            used = true
            RunState.collect_fuse()
            queue_free()
        "relay":
            if used: return
            if RunState.activate_relay(objective_index):
                used = true
                relay_art.modulate = Color("9affbd")
                relay_art.scale = Vector2.ONE * 0.46
        "checkpoint":
            RunState.set_checkpoint(global_position + Vector2(0, 22))
            used = true
            icon.color = Color("ffb45d")
        "exit":
            if RunState.gate_open:
                used = true
                RunState.advance_level()
            else:
                RunState.notice.emit("EMERGENCY EXIT LOCKED — RESTORE ALL THREE RELAYS")
        "record":
            RunState.notice.emit(label_text if not label_text.is_empty() else "FIELD NOTE // RELAY PHASE KEY: STABLE > GLITCHED > STABLE")
