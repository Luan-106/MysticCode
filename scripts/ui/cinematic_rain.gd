extends Control

var drops: Array[Vector2] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	for i in 150:
		drops.append(Vector2(rng.randf_range(0.0, 1280.0), rng.randf_range(0.0, 720.0)))

func _process(delta: float) -> void:
	for i in range(drops.size()):
		var drop := drops[i]
		drop += Vector2(-42.0, 300.0) * delta
		if drop.y > 735.0:
			drop = Vector2(rng.randf_range(0.0, 1280.0), -12.0)
		drops[i] = drop
	queue_redraw()

func _draw() -> void:
	for drop in drops:
		draw_line(drop, drop + Vector2(-5.0, 17.0), Color(0.52, 0.83, 0.85, 0.22), 1.0)
