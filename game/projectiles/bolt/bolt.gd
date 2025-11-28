extends Area2D
class_name Bolt


@export var projectile_stats: ProjectileStats
@export var explosion_scene: PackedScene
var age: float = 0.0
var heading: Vector2 = Vector2(1., 0.)
var velocity: Vector2 = Vector2.ZERO


func fire(
		initial_transform: Transform2D,
		target: Vector2,
		spawn_offset: Vector2,
		mask: int
	):
	global_transform = initial_transform
	collision_mask = mask
	var heading_angle := global_position.angle_to_point(target)
	heading = Vector2.from_angle(heading_angle)
	position += spawn_offset.rotated(heading_angle)
	rotation = heading_angle


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _physics_process(delta: float) -> void:
	if projectile_stats:
		age += delta
		velocity += projectile_stats.acceleration * heading * delta
		velocity = Vector.clamp_vector2_length(velocity, projectile_stats.max_speed)
		position += velocity
		rotation = velocity.angle()
		if projectile_stats.lifetime < age:
			queue_free()


func on_body_entered(node: Node2D) -> void:
	if projectile_stats:
		var damagable := GameActor.get_damagable(node)
		if damagable:
			damagable.take_damage(projectile_stats.damage)
	queue_free()
