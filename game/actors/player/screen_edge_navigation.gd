extends Node2D
class_name ScreenEdgeNavigation


@onready var enemy_dots: Node2D = $EnemyDots
@onready var enemy_tracking_area: Area2D = $EnemyTrackingArea
@onready var goal_dots: Node2D = $GoalDots


@export var nav_texture := preload("res://assets/shapes/purple_circle_24x24.png")
@export var goal_dot_scene := preload("res://particles/goal_dot.tscn")
@export var margin: Vector2 = Vector2(32., 32.)
@export var max_enemy_dots: int = 40
@export var sprite_scale: Vector2 = Vector2(.75, .75)
@export var active_alpha: float = .75
var enemy_dot_pool: Array[Sprite2D]
var enemy_dot_tweens: Array[Tween]
var goals: Array[Node2D]


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
			var nav_position := get_nav_position(enemy.global_position, rect)
			dot.global_position = nav_position
			dot.modulate.a = active_alpha
	for i in range(dotIdx, max_enemy_dots):
		enemy_dot_pool[i].modulate.a = 0.
	
	var current_goal_dot_idx: int = 0
	var current_goal_dots := goal_dots.get_children()
	for goal in goals:
		if is_instance_valid(goal) and current_goal_dot_idx < current_goal_dots.size():
			var goal_position := goal.global_position
			var goal_dot = current_goal_dots[current_goal_dot_idx]
			current_goal_dot_idx += 1
			if goal_dot is GoalDot:
				if !rect.has_point(goal_position):
					var nav_position := get_nav_position(goal_position, rect)
					goal_dot.modulate.a = .5
					goal_dot.global_position = nav_position
					goal_dot.show()
				else:
					goal_dot.hide()


func get_nav_position(target_global_position: Vector2, navigration_rect: Rect2) -> Vector2:
	return Vector2(
		clampf(target_global_position.x, navigration_rect.position.x, navigration_rect.end.x),
		clampf(target_global_position.y, navigration_rect.position.y, navigration_rect.end.y)
	)


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
	
func add_goal(node: Node2D) -> void:
	if goal_dot_scene and goal_dot_scene.can_instantiate():
		var goal_dot := goal_dot_scene.instantiate()
		if goal_dot.has_method('fadeout'):
			node.tree_exiting.connect(
				func(): 
					if is_instance_valid(goal_dot):
						goal_dot.fadeout()
			)
			var damagable = GameActor.get_damagable(node)
			if damagable:
				damagable.on_death.connect(
					func(node: Node2D): 
						if is_instance_valid(goal_dot):
							goal_dot.fadeout()
				)
		goals.append(node)
		goal_dots.add_child(goal_dot)
