extends CharacterBody2D
class_name HunterDrone


@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged
@export var enemy_move_and_collide: PhysicsBodyMoveAndCollide
var actor_type := GameActor.ActorType.ENEMY

@onready var pinwheel_scanner: PinwheelScanner = $PinwheelScanner
@onready var targeting_area: TargetingArea = $TargetingArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var stop_radius: float = 20.0
var last_known_target_location: Vector2 = Vector2.ZERO


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		if on_death_handler:
			on_death_handler.bind_to_node(self)
		if tween_damaged:
			tween_damaged.bind_to_node(self)
	if steerable:
		steerable.steering_strategies.append(direction_steering)
		


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
				#target = global_position + Vector2(0, -1)
				var avoid := pinwheel_scanner.scan()
				print(avoid)
				direction_steering.goal_vector = (global_position.direction_to(target) + avoid) * steerable.get_max_speed()
				steerable.steer(delta)
			else:
				steerable.slow(delta)
			velocity = steerable.velocity
		else:
			velocity = Vector2.ZERO
			
		
		enemy_move_and_collide.move_and_collide(self, delta)
