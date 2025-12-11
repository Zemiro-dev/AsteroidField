extends Node2D
@onready var tl: Sprite2D = $TL
@onready var tr: Sprite2D = $TR
@onready var bl: Sprite2D = $BL
@onready var br: Sprite2D = $BR


func _physics_process(delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if !camera: return
	var size = get_viewport_rect().size / camera.zoom
	var rect = Rect2(
		camera.global_position - size/2,
		size
	)

	tl.global_position = rect.position
	tr.global_position = rect.position + Vector2(rect.size.x, 0.)
	bl.global_position = rect.position + Vector2(0., rect.size.y)
	br.global_position = rect.position + rect.size
