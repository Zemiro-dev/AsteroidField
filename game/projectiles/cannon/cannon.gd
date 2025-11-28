extends TargetingArea
class_name Cannon


@export var enabled: bool = true
@export var stats: CannonStats
@export var projectile_scene: PackedScene
@export var spawn_offset: Vector2 = Vector2.ZERO
var time_since_last_shot: float = 0


func _ready() -> void:
	if stats:
		var rng = RandomNumberGenerator.new()
		stats.time_between_shots += rng.randf() * .001


func _physics_process(delta: float) -> void:
	if stats and time_since_last_shot > stats.time_between_shots and enabled:
		var target = get_target()
		if target:
			fire(target.global_position)
			time_since_last_shot = 0.0
	if stats and time_since_last_shot < stats.time_between_shots:
		time_since_last_shot += delta


func fire(target: Vector2) -> void:
	if projectile_scene:
		var projectile: Node2D = projectile_scene.instantiate()
		if projectile is Bolt:
			projectile.fire(
				global_transform,
				target,
				spawn_offset, 
				collision_mask + blocked_by
			)
		GlobalSignals.request_projectile_spawn.emit(projectile)


func _hitscan(target:Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target, collision_mask, [self])
	var result := space_state.intersect_ray(query)
	var obj = result.get('collider')
	if obj is Object:
		var damagable = GameActor.get_damagable(obj)
		if damagable:
			damagable.take_damage(2)
