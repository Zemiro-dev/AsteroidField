extends CharacterBody2D
class_name HunterDrone


@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged
@export var enemy_move_and_collide: PhysicsBodyMoveAndCollide
var actor_type := GameActor.ActorType.ENEMY

@onready var wall_avoid_scanner: PinwheelScanner = $WallAvoidScanner
@onready var enemy_avoid_scanner: PinwheelScanner = $EnemyAvoidScanner
@onready var targeting_area: TargetingArea = $TargetingArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Hurtbox = $Hurtbox

@export var stop_radius: float = 20.0
var last_known_target_location: Vector2 = Vector2.ZERO

@export var raw_offset_vector: Vector2 = Vector2.ZERO
var target_offset_vector: Vector2
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		if on_death_handler:
			on_death_handler.bind_to_node(self)
		if tween_damaged:
			tween_damaged.bind_to_node(self)
	if steerable:
		steerable.steering_strategies.append(direction_steering)
		hurtbox.on_damage_dealt.connect(self_knockback)
	target_offset_vector = raw_offset_vector.rotated(rng.randf_range(0, 2 * PI))


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)
	var target = targeting_area.get_target()
	if target.is_zero_approx() and !last_known_target_location.is_zero_approx():
		target = last_known_target_location
	if steerable:
		if !damagable.is_dead:
			if !target.is_zero_approx() and global_position.distance_to(target) > stop_radius:
				last_known_target_location = target
				var wall_avoid := wall_avoid_scanner.scan()
				var enemy_avoid := enemy_avoid_scanner.scan()
				var target_goal := enemy_avoid if !enemy_avoid.is_zero_approx() else global_position.direction_to(target + target_offset_vector)
				direction_steering.goal_vector = (global_position.direction_to(target) + wall_avoid + enemy_avoid).normalized() * steerable.get_max_speed()
				steerable.steer(delta)
			else:
				steerable.slow(delta)
			rotation = steerable.velocity.angle()
		else:
			steerable.halt()
			
		if steerable.should_overspeed_break():
			steerable.overspeed_break(delta)
			
		enemy_move_and_collide.move_and_collide(self, delta)

func self_knockback(_t: Node2D, _d: int):
	if steerable:
		var heading := steerable.velocity.normalized()
		steerable.knockback(-heading * 3000.)
