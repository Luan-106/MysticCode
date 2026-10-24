extends Area2D
class_name FacilityHazard
@export_enum("Stable", "Corrupted", "Both") var reality_mode := 1
@export var rect_size := Vector2(64, 26)
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shape: RectangleShape2D = collision.shape as RectangleShape2D
@onready var polygon: Polygon2D = $Polygon2D
func _ready() -> void:
    add_to_group("reality_object")
    if reality_mode == 0: add_to_group("reality_stable")
    elif reality_mode == 1: add_to_group("reality_corrupted")
    shape = shape.duplicate() as RectangleShape2D
    collision.shape = shape
    shape.size = rect_size
    polygon.polygon = PackedVector2Array([Vector2(-rect_size.x/2,-rect_size.y/2), Vector2(rect_size.x/2,-rect_size.y/2), Vector2(rect_size.x/2,rect_size.y/2), Vector2(-rect_size.x/2,rect_size.y/2)])
    polygon.color = Color("ec4254")
    body_entered.connect(_on_body_entered)
    set_reality_active(reality_mode == RunState.reality or reality_mode == RunState.REALITY_BOTH)
func set_reality_active(active: bool) -> void:
    visible = active
    if is_node_ready(): collision.set_deferred("disabled", not active)
func world_bounds() -> Rect2:
    return Rect2(global_position - rect_size * 0.5, rect_size)
func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and body.has_method("take_damage"):
        body.call("take_damage", 1, Vector2(-signf(body.global_position.x - global_position.x) * 180.0, -250.0))





func _add_warning_art() -> void:
    var crown := Line2D.new()
    crown.name = "WarningCrown"
    crown.points = PackedVector2Array([Vector2(-rect_size.x * 0.5 + 2.0, -rect_size.y * 0.5 + 1.0), Vector2(rect_size.x * 0.5 - 2.0, -rect_size.y * 0.5 + 1.0)])
    crown.width = 2.5
    crown.default_color = Color("ff7880", 0.95)
    crown.antialiased = true
    add_child(crown)
    var count := maxi(3, int(rect_size.x / 22.0))
    for index in count:
        var x := -rect_size.x * 0.5 + (float(index) + 0.5) * rect_size.x / float(count)
        var spike := Polygon2D.new()
        spike.name = "LiveSpike%d" % index
        spike.position = Vector2(x, -rect_size.y * 0.5 + 1.0)
        spike.polygon = PackedVector2Array([Vector2(-6,-1),Vector2(0,-10),Vector2(6,-1)])
        spike.color = Color("f15367")
        add_child(spike)
