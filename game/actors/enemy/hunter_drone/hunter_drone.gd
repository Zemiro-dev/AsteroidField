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

@export var charge_distance: float = 400.
@export var charge_max_speed: float = 5000
var original_max_speed: float


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		if on_death_handler:
			on_death_handler.bind_to_node(self)
		if tween_damaged:
			tween_damaged.bind_to_node(self)
	if steerable:
		steerable.reset()
		steerable.steering_strategies.append(direction_steering)
		hurtbox.on_damage_dealt.connect(self_knockback)
		original_max_speed = steerable.base_max_speed
	target_offset_vector = raw_offset_vector.rotated(rng.randf_range(0, 2 * PI))


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)
	var target := Vector2.ZERO
	var target_node = targeting_area.get_target()
	var target_damagable = GameActor.get_damagable(target_node) if target_node else null
	if !target_node and !last_known_target_location.is_zero_approx():
		target = last_known_target_location
	if target_node:
		target = target_node.global_position
	if target_node and steerable and target_node.global_position.distance_to(global_position) < charge_distance:
		steerable.base_max_speed = charge_max_speed
	else:
		steerable.base_max_speed = original_max_speed
	if steerable:
		if !damagable.is_dead:
			if (!target_damagable or !target_damagable.is_dead) and !target.is_zero_approx() and global_position.distance_to(target) > stop_radius:
				last_known_target_location = target
				var wall_avoid := wall_avoid_scanner.scan()
				var enemy_avoid := enemy_avoid_scanner.scan()
				var target_goal := enemy_avoid if !enemy_avoid.is_zero_approx() else global_position.direction_to(target + target_offset_vector)
				direction_steering.goal_vector = (global_position.direction_to(target) + wall_avoid + enemy_avoid).normalized() * steerable.get_max_speed()
				steerable.steer(delta)
			else:
				steerable.slow(delta)			
		else:
			steerable.halt()
		if !steerable.velocity.is_zero_approx():
			rotation = steerable.velocity.angle()
			
		if steerable.should_overspeed_break():
			steerable.overspeed_break(delta)
			
		enemy_move_and_collide.move_and_collide(self, delta)

func self_knockback(_t: Node2D, _d: int):
	if steerable:
		var heading := steerable.velocity.normalized()
		steerable.knockback(-heading * 3000.)
