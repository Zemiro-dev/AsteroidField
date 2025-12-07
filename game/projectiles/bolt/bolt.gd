extends Area2D
class_name Bolt


@export var stats: ProjectileStats
@export var explosion_scene: PackedScene
@export var sound_scene: PackedScene
var age: float = 0.0
var heading: Vector2 = Vector2(1., 0.)
var velocity: Vector2 = Vector2.ZERO


func fire(
		initial_transform: Transform2D,
		target: Vector2,
		spawn_offset: Vector2,
		mask: int,
		damage_boost: int = 0
	):
	global_transform = initial_transform
	collision_mask = mask
	var heading_angle := global_position.angle_to_point(target)
	heading = Vector2.from_angle(heading_angle)
	position += spawn_offset.rotated(heading_angle)
	rotation = heading_angle
	if stats and damage_boost:
		stats.damage += damage_boost
	GlobalSignals.request_world_sound_spawn.emit(self, sound_scene)
	reset_physics_interpolation()


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _physics_process(delta: float) -> void:
	if stats:
		age += delta
		velocity += stats.acceleration * heading * delta
		velocity = Vector.clamp_vector2_length(velocity, stats.max_speed)
		position += velocity
		rotation = velocity.angle()
		if stats.lifetime < age:
			on_death()


func on_body_entered(node: Node2D) -> void:
	if stats:
		var damagable := GameActor.get_damagable(node)
		if damagable:
			damagable.take_damage(stats.damage)
	on_death()


func on_death() -> void:
	GlobalSignals.request_explosion_spawn.emit(self, explosion_scene)
	queue_free()
