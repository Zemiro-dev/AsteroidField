extends Node2D


@export var inner_spawn_radius: float = 1200.
@export var outer_spawn_radius: float = 2000.
@export var enemy_scene: PackedScene
@export var clear_area_radius: float = 64
@export var time_between_dangerup: float = 20.
@export var time_between_spawnup: float = 3.
@export var time_between_spawns: float = .05
@export_flags_2d_physics var blocked_by: int
var enemies_to_spawn := 0
var time_since_last_spawnup: float = 0.
var time_since_danger_up: float = 0.
var danger = 0
@onready var time_since_last_spawn: float = time_between_spawns


func _process(delta: float) -> void:
	if time_since_danger_up < time_between_dangerup:
		time_since_danger_up += delta
	if time_since_last_spawn < time_between_spawns:
		time_since_last_spawn += delta
	if time_since_last_spawnup < time_between_spawnup:
		time_since_last_spawnup += delta
	
	if time_since_danger_up >= time_between_dangerup:
		danger += max(danger/3, 1)
		time_since_danger_up = 0.
	
	if time_since_last_spawnup >= time_between_spawnup:
		enemies_to_spawn += danger
		time_since_last_spawnup = 0.
		
	if enemies_to_spawn > 0 and time_since_last_spawn >= time_between_spawns:
		var spawn_position = global_position + get_rng_spawn_point()
		if (test_spawn(spawn_position)):
			spawn(spawn_position)


func get_rng_spawn_point() -> Vector2:
	var rng_angle := randf_range(0, TAU)
	return Vector2(
		randf_range(inner_spawn_radius, outer_spawn_radius),
		0.
	).rotated(rng_angle)


func test_spawn(test_position: Vector2) -> bool:
	return Physics.is_circle_empty(test_position, clear_area_radius, blocked_by)


func spawn(spawn_position: Vector2):
	if enemy_scene and enemy_scene.can_instantiate():
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_position
		enemies_to_spawn -= 1
		time_since_last_spawn = 0.
		GlobalSignals.request_enemy_spawn.emit(enemy)
