extends Node2D
class_name FacilityPlatform

@export_enum("Stable", "Corrupted", "Both") var reality_mode := 0
@export var rect_size := Vector2(180, 28)
@export var tint := Color("52716f")
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var shape: RectangleShape2D = collision.shape as RectangleShape2D
@onready var polygon: Polygon2D = $Polygon2D
func _ready() -> void:
	add_to_group("reality_object")
	add_to_group("reality_platforms")
	if reality_mode == 0: add_to_group("reality_stable")
	elif reality_mode == 1: add_to_group("reality_corrupted")
	shape = shape.duplicate() as RectangleShape2D
	collision.shape = shape
	shape.size = rect_size
	polygon.polygon = PackedVector2Array([Vector2(-rect_size.x/2,-rect_size.y/2), Vector2(rect_size.x/2,-rect_size.y/2), Vector2(rect_size.x/2,rect_size.y/2), Vector2(-rect_size.x/2,rect_size.y/2)])
	polygon.color = tint
	_add_surface_details()
	set_reality_active(reality_mode == RunState.reality or reality_mode == RunState.REALITY_BOTH)
func set_reality_active(active: bool) -> void:
	visible = active
	if is_node_ready(): collision.set_deferred("disabled", not active)
func world_bounds() -> Rect2:
	return Rect2(global_position - rect_size * 0.5, rect_size)


func _add_surface_details() -> void:
	var wide_floor := rect_size.x > 600.0
	var glow := Color("89d9ca") if reality_mode != 1 else Color("fa7892")
	glow.a = 0.14 if wide_floor else 0.88
	var top_edge := Line2D.new()
	top_edge.name = "LitTopEdge"
	top_edge.points = PackedVector2Array([Vector2(-rect_size.x * 0.5 + 4.0, -rect_size.y * 0.5 + 1.5), Vector2(rect_size.x * 0.5 - 4.0, -rect_size.y * 0.5 + 1.5)])
	top_edge.width = 1.3 if wide_floor else 2.6
	top_edge.default_color = glow
	top_edge.antialiased = true
	add_child(top_edge)
	var lower_lip := Polygon2D.new()
	lower_lip.name = "ShadowedLowerLip"
	lower_lip.polygon = PackedVector2Array([Vector2(-rect_size.x * 0.5, rect_size.y * 0.5 - 4.0), Vector2(rect_size.x * 0.5, rect_size.y * 0.5 - 4.0), Vector2(rect_size.x * 0.5 - 7.0, rect_size.y * 0.5), Vector2(-rect_size.x * 0.5 + 7.0, rect_size.y * 0.5)])
	lower_lip.color = tint.darkened(0.42)
	add_child(lower_lip)
	if wide_floor:
		return
	for side in [-1.0, 1.0]:
		var bolt := Polygon2D.new()
		bolt.name = "EdgeBolt"
		bolt.position = Vector2(side * (rect_size.x * 0.5 - 9.0), 1.0)
		bolt.polygon = PackedVector2Array([Vector2(0,-3),Vector2(3,-1.5),Vector2(3,1.5),Vector2(0,3),Vector2(-3,1.5),Vector2(-3,-1.5)])
		bolt.color = Color("e8b578", 0.82)
		add_child(bolt)
