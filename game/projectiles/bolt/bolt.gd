extends Area2D
class_name Bolt


@export var stats: ProjectileStats
@export var explosion_scene: PackedScene
@export var sound_scene: PackedScene
var age: float = 0.0
var heading: Vector2 = Vector2(1., 0.)
var velocity: Vector2 = Vector2.ZERO
var levelable: Levelable


func fire(
		initial_transform: Transform2D,
		target: Vector2,
		spawn_offset: Vector2,
		mask: int,
		_levelable: Levelable = null,
		is_extra: bool = false
	):
	levelable = _levelable
	global_transform = initial_transform
	collision_mask = mask
	var heading_angle := global_position.angle_to_point(target)
	var radial_spread: float = 0.
	var spread := Vector2.ZERO
	if stats:
		radial_spread = randf_range(-stats.radial_spread/2., stats.radial_spread/2.)
		spread = Vector2(
			randf_range(-stats.spread.x / 2., stats.spread.x / 2.),
			randf_range(-stats.spread.y / 2, stats.spread.y / 2.)
		).rotated(heading_angle)
		spread = spread.rotated(global_transform.get_rotation())
	global_position += spawn_offset.rotated(heading_angle) + spread
	heading = Vector2.from_angle(heading_angle + radial_spread)
	rotation = heading_angle + radial_spread
	if sound_scene and sound_scene.can_instantiate():
		var sound := sound_scene.instantiate()
		if sound is AudioStreamPlayer2D:
			sound.global_position = global_position
			if !is_extra:
				GlobalSignals.request_sound_spawn.emit(sound)
	reset_physics_interpolation()


func get_time_between_shots() -> float:
	if !stats: return 0.0
	
	return stats.time_between_shots * (1.0 if !levelable else levelable.stats.projectile_time_between_shots_mult)


func get_damage() -> int:
	if !stats: return 1
	
	return stats.damage + (0 if !levelable else levelable.stats.projectile_damage_up)


func get_max_speed() -> float:
	if !stats: return 0.
	
	return stats.max_speed + (0. if !levelable else levelable.stats.projectile_max_speed_up)


func get_acceleration() -> float:
	if !stats: return 0.
	
	return stats.acceleration + (0. if !levelable else levelable.stats.projectile_acceleration_up)


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _physics_process(delta: float) -> void:
	if stats:
		age += delta
		velocity += get_acceleration() * heading * delta
		velocity = Vector.clamp_vector2_length(velocity, get_max_speed())
		position += velocity * delta
		rotation = velocity.angle()
		if stats.lifetime < age:
			on_death()


func on_body_entered(node: Node2D) -> void:
	if stats:
		var damagable := GameActor.get_damagable(node)
		if damagable:
			damagable.take_damage(get_damage())
	explode()
	on_death()


func explode() -> void:	
	GlobalSignals.request_explosion_spawn.emit(self, explosion_scene)


func on_death() -> void:
	queue_free()
