extends Node2D


@onready var enemy_dots: Node2D = $EnemyDots
@onready var enemy_tracking_area: Area2D = $EnemyTrackingArea


@export var nav_texture := preload("res://assets/shapes/purple_circle_24x24.png")
@export var margin: Vector2 = Vector2(24., 24.)
@export var max_enemy_dots: int = 40
@export var sprite_scale: Vector2 = Vector2(.75, .75)
@export var active_alpha: float = .75
var enemy_dot_pool: Array[Sprite2D]
var enemy_dot_tweens: Array[Tween]


func _ready() -> void:
	enemy_dot_pool.resize(max_enemy_dots)
	for i in range(0, max_enemy_dots):
		var enemy_dot = Sprite2D.new()
		enemy_dot.scale = sprite_scale
		enemy_dot.texture = nav_texture
		enemy_dot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		enemy_dot.modulate.a = 0.
		enemy_dot_pool[i] = enemy_dot
		enemy_dots.add_child(enemy_dot)
	enemy_dot_tweens.resize(max_enemy_dots)
	show()


func _physics_process(_delta: float) -> void:
	var enemies := enemy_tracking_area.get_overlapping_bodies()
	var rect := get_navigation_rect(margin)
	var center := rect.get_center()
	var dotIdx := 0
	for enemy in enemies:
		if !rect.has_point(enemy.global_position) and dotIdx < max_enemy_dots: 
			var dot = enemy_dot_pool[dotIdx]
			dotIdx += 1
			var nav_position := Vector2(
				clampf(enemy.global_position.x, rect.position.x, rect.end.x),
				clampf(enemy.global_position.y, rect.position.y, rect.end.y)
			)
			dot.global_position = nav_position
			dot.modulate.a = active_alpha
	for i in range(dotIdx, max_enemy_dots):
		enemy_dot_pool[i].modulate.a = 0.
		


func get_navigation_rect(margin: Vector2 = Vector2.ZERO) -> Rect2:
	var zoom: Vector2 = Vector2(1., 1.)
	var center: Vector2 = global_position
	var camera = get_viewport().get_camera_2d()
	if camera:
		zoom = camera.zoom
		center = camera.global_position
		
	var size = (get_viewport_rect().size - margin) / zoom
	return Rect2(
		center - size/2,
		size
	)
	
