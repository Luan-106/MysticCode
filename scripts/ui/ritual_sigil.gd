extends Control

var clock := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	clock += delta
	rotation = sin(clock * 0.18) * 0.035
	queue_redraw()

func _draw() -> void:
	var c := size * 0.5
	var pulse := 0.55 + sin(clock * 2.0) * 0.12
	var cyan := Color(0.35, 0.88, 0.84, pulse)
	var amber := Color(0.93, 0.55, 0.31, pulse * 0.72)
	for radius in [54.0, 72.0, 105.0]:
		draw_arc(c, radius, 0.0, TAU, 96, cyan if radius != 72.0 else amber, 1.6, true)
	var points := PackedVector2Array()
	for i in 6:
		var a := -PI * 0.5 + TAU * float(i) / 6.0
		points.append(c + Vector2(cos(a), sin(a)) * 104.0)
	for i in 6:
		draw_line(points[i], points[(i + 2) % 6], amber, 1.4, true)
		draw_line(points[i], points[(i + 3) % 6], cyan, 0.8, true)
		draw_circle(points[i], 3.0, amber)
	draw_circle(c, 8.0 + sin(clock * 2.0) * 1.5, Color(0.96, 0.20, 0.30, 0.76))
	draw_circle(c, 18.0 + sin(clock * 2.0) * 2.0, Color(0.75, 0.20, 0.38, 0.23), false, 1.4)
