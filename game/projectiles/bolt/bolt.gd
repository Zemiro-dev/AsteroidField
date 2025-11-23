extends Area2D
class_name Bolt


@export var projectile_stats: ProjectileStats
@export var explosion_scene: PackedScene
var age: float = 0.0
var heading: Vector2 = Vector2(1., 0.)


func chamber(initial_transform: Transform2D, target: Vector2, mask: int):
	global_transform = initial_transform
	collision_mask = mask
	heading = Vector2.from_angle(global_position.angle_to_point(target))


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _physics_process(delta: float) -> void:
	if projectile_stats:
		age += delta
		rotation = heading.angle()
		position += projectile_stats.speed * heading * delta
		if projectile_stats.lifetime < age:
			print('boom 1')
			queue_free()


func on_body_entered(node: Node2D) -> void:
	if projectile_stats:
		var damagable := GameActor.get_damagable(node)
		if damagable:
			print('take damage')
			damagable.take_damage(projectile_stats.damage)
	print('boom 2')
	queue_free()
