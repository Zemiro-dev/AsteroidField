extends CharacterBody2D
class_name HunterDrone


@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged
var actor_type := GameActor.ActorType.ENEMY

@onready var targeting_area: TargetingArea = $TargetingArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer


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
	if steerable:
		if !damagable.is_dead:
			if !target.is_zero_approx():
				direction_steering.goal_vector = global_position.direction_to(target) * steerable.get_max_speed()
				steerable.steer(delta)
			else:
				steerable.slow(delta)
			velocity = steerable.velocity
		else:
			velocity = Vector2.ZERO
			
		
		move_and_slide()
