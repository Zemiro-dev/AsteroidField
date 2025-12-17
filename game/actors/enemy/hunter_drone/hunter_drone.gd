extends CharacterBody2D
class_name HunterDrone


@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged
@export var enemy_move_and_collide: PhysicsBodyMoveAndCollide
@export var collision_scene: PackedScene
var actor_type := GameActor.ActorType.ENEMY

@onready var avoid_scanner: PinwheelScanner = $AvoidScanner
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

@export var tick_rate: int = 5
var tick: int = 0
var hunt_action: Callable = func(_delta: float = 0.): pass
var turn_direction := 0.


func _ready() -> void:
	tick = randi_range(0, tick_rate)
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
		hurtbox.on_damage_dealt.connect(
			func (_t: Node2D, _d: int):
				GlobalSignals.request_world_sound_spawn.emit(self, collision_scene)
				GlobalSignals.request_camera_shake.emit(.2, 500)
		)
		original_max_speed = steerable.base_max_speed
	target_offset_vector = raw_offset_vector.rotated(rng.randf_range(0, 2 * PI))
	turn_direction = [-1., 1.].pick_random()


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)
	
	
	tick = clampi(tick + 1, 0, tick_rate)
		
	if steerable:
		if tick >= tick_rate:
			avoid_scanner.enabled = true
			tick = 0
			hunt_action = hunt()
			avoid_scanner.enabled = false
		
		hunt_action.call(delta)
		
		if !steerable.velocity.is_zero_approx():
			rotation = steerable.velocity.angle()
			
		enemy_move_and_collide.move_and_collide(self, delta)


func hunt() -> Callable:
	var target := Vector2.ZERO
	var target_node = targeting_area.get_target()
	var target_damagable = GameActor.get_damagable(target_node) if target_node else null
	var action: Callable = func(): pass
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
				var avoid := avoid_scanner.scan()
				var target_goal_vector := global_position.direction_to(target)
				if avoid.dot(target_goal_vector) < .0 and avoid.length() > .25:
					target_goal_vector = target_goal_vector.rotated(PI / 2. * turn_direction)
				direction_steering.goal_vector = (target_goal_vector + avoid).normalized() * steerable.get_max_speed()
				action = steerable.steer()
			else:
				action = steerable.slow()
		else:
			action = steerable.halt()
	return action

func self_knockback(_t: Node2D, _d: int):
	if steerable:
		var heading := steerable.velocity.normalized()
		steerable.knockback(-heading * 3000.)
