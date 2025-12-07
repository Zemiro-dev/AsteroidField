extends TargetingArea
class_name Cannon


@export var enabled: bool = true
@export var projectile_scene: PackedScene
@export var spawn_offset: Vector2 = Vector2.ZERO
var damagable: BaseDamagable
var levelable: Levelable
var time_until_next_shot: float = 0.
var time_since_last_shot: float = 0.

var wielder: Node2D:
	set(value):
		wielder = value
		damagable = GameActor.get_damagable(wielder)
		damagable.on_death.connect(func(actor: Node2D): enabled = false)
		levelable = GameActor.get_levelable(wielder)


func _ready() -> void:
	var rng = RandomNumberGenerator.new()


func _physics_process(delta: float) -> void:
	if can_fire() and enabled:
		var target = get_target()
		if target:
			time_until_next_shot = fire(target, delta)
			time_since_last_shot = 0.0
	if !can_fire():
		time_since_last_shot += delta


func can_fire() -> bool:
	return time_until_next_shot <= time_since_last_shot


## returns time until next show allowed
func fire(target_node: Node2D, delta: float) -> float:
	if projectile_scene:
		var projectile: Node2D = projectile_scene.instantiate()
		GlobalSignals.request_projectile_spawn.emit(projectile)
		if projectile is Bolt:
			var target: Vector2 = target_node.global_position
			var steerable := GameActor.get_steerable(target_node)
			if steerable:
				var look_ahead: Vector2 = target + steerable.velocity * delta * (30000. / projectile.get_max_speed())
				var to_target := global_position.direction_to(target)
				var to_look_ahead := global_position.direction_to(look_ahead)
				if to_target.dot(to_look_ahead) > 0:
					target = look_ahead
			var levelable = GameActor.get_levelable(wielder)
			projectile.fire(
				global_transform,
				target,
				spawn_offset, 
				collision_mask + blocked_by,
				levelable
			)
			return projectile.get_time_between_shots()
	return 0.


func _hitscan(target:Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target, collision_mask, [self])
	var result := space_state.intersect_ray(query)
	var obj = result.get('collider')
	if obj is Object:
		var damagable = GameActor.get_damagable(obj)
		if damagable:
			damagable.take_damage(2)
